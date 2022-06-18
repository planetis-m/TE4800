import strutils, strformat

type
   DxfWriter* = object
      content: string

   TextAlign* {.pure.} = enum
      Left, Center, Right,
      BottomLeft, BottomCenter, BottomRight,
      MiddleLeft, MiddleCenter, MiddleRight,
      TopLeft, TopCenter, TopRight

   LineType* {.pure.} = enum
      Continuous, # Default
      Center, CenterX2, Center2,
      Dashed, DashedX2, Dashed2,
      Phantom, PhantomX2, Phantom2,
      DashDot, DashDotX2, DashDot2,
      Dot, DotX2, Dot2,
      Divide, DivideX2, Divide2

   AciColor* = distinct int

using
   dxf: var DxfWriter

const
   NDigits = 6 # output precision of floats
   Preface = slurp("preface.txt")

   TextAlignMap = [
      Left: (0, 0),
      Center: (1, 0),
      Right: (2, 0),
      BottomLeft: (0, 1),
      BottomCenter: (1, 1),
      BottomRight: (2, 1),
      MiddleLeft: (0, 2),
      MiddleCenter: (1, 2),
      MiddleRight: (2, 2),
      TopLeft: (0, 3),
      TopCenter: (1, 3),
      TopRight: (2, 3)]

   Red* = AciColor(1)
   Yellow* = AciColor(2)
   Green* = AciColor(3)
   Cyan* = AciColor(4)
   Blue* = AciColor(5)
   Magenta* = AciColor(6)
   Default* = AciColor(7) # black/white
   DarkGray* = AciColor(8)
   LightGray* = AciColor(9)
   # Special
   ByBlock* = AciColor(0)
   ByLayer* = AciColor(256)

template checkIfInitialized() =
   if dxf.content.len == 0:
      dxf.content = newStringOfCap(1_200)
      dxf.content.add(Preface)
      dxf.content.add("0\nSECTION\n2\nENTITIES\n")

template addTag(content: string, code, value) =
   content.add(&"{code}\n{value}\n")

template dxfAttribs(content: string, layer: string, color: AciColor, linetype: LineType) =
   assert(0 <= int(color) and int(color) < 257,
      "color has to be an integer in the range from 0 to 256.")
   content.addTag(8, layer)
   content.addTag(6, toUpperAscii($linetype))
   content.addTag(62, color)

template dxfVertex(content: string, vertex; code = 10) =
   content.addTag(code, vertex.x.formatFloat(ffDecimal, NDigits))
   content.addTag(code+10, vertex.y.formatFloat(ffDecimal, NDigits))
   when compiles(vertex.z):
      content.addTag(code+20, vertex.z.formatFloat(ffDecimal, NDigits))

proc line[T](dxf; p1, p2: T, layer = "0", color = Default, linetype = Continuous) =
   checkIfInitialized()
   dxf.content.add("0\nLINE\n")
   dxf.content.addAttribs(layer, color, linetype)
   dxf.content.addVertex(p1, 10)
   dxf.content.addVertex(p2, 11)

proc face[T](dxf; p1, p2, p3, p4: T, layer = "0", color = Default, linetype = Continuous) =
   checkIfInitialized()
   dxf.content.add("0\n3DFACE\n")
   dxf.content.addAttribs(layer, color, linetype)
   dxf.content.addVertex(p1, 10)
   dxf.content.addVertex(p2, 11)
   dxf.content.addVertex(p3, 12)
   dxf.content.addVertex(p4, 13)

proc point[T](dxf; layer: string, p1: T, layer = "0", color = Default, linetype = Continuous) =
   checkIfInitialized()
   dxf.content.add("0\nPOINT\n")
   dxf.content.addAttribs(layer, color, linetype)
   dxf.content.addVertex(p1, 10)

proc circle[T](dxf; p1: T, radius: float; layer = "0", color = Default, linetype = Continuous) =
   checkIfInitialized()
   dxf.content.add("0\nCIRCLE\n")
   dxf.content.addAttribs(layer, color, linetype)
   dxf.content.addVertex(p1, 10)
   dxf.content.addTag(40, radius.formatFloat(ffDecimal, NDigits))

proc arc[T](dxf; p1: T, radius: float, start = 0, stop = 360.0, layer = "0", color = Default, linetype = Continuous) =
   checkIfInitialized()
   dxf.content.add("0\nARC\n")
   dxf.content.addAttribs(layer, color, linetype)
   dxf.content.addVertex(p1, 10)
   dxf.content.addTag(40, radius.formatFloat(ffDecimal, NDigits))
   dxf.content.addTag(50, start.formatFloat(ffDecimal, NDigits))
   dxf.content.addTag(51, stop.formatFloat(ffDecimal, NDigits))

proc text[T](dxf; p1: T, size: float, s: string; layer = "0", color = Default, linetype = Continuous) =
   checkIfInitialized()
   dxf.content.add("0\nTEXT\n")
   dxf.content.addAttribs(layer, color, linetype)
   dxf.content.addVertex(p1, 10)
   dxf.content.addTag(40, size.formatFloat(ffDecimal, NDigits))
   dxf.content.add("50\n")
   dxf.content.add("0\n1\n")
   dxf.content.add(s)

proc save(dxf; filename: string) =
   checkIfInitialized()
   dxf.content.add("0\nENDSEC\n0\nEOF\n")
   var f: File
   if open(f, filename, fmWrite):
      f.write(dxf.content)
      close(f)

when isMainModule:
   type
      Point3D = object
         x, y, z: float
   proc p3(x, y, z: float): Point3D = Point3D(x: x, y: y, z: z)
   var dxf: DxfWriter
   dxf.line(p3(0.0, 0.0, 0.0), p3(1.0, 1.0, 0.0), "lines")
   dxf.face(p3(0.0, 0.0, 0.0), p3(1.0, 0.0, 0.0), p3(1.0, 1.0, 0.0), p3(0.0, 1.0, 0.0), "faces")
   dxf.point(p3(0.0, 0.0, 0.0), "points")
   dxf.circle(p3(0.0, 0.0, 0.0), 0.1, "circles")
   dxf.text(p3(0.0, 0.0, 0.0), 0.1, "structural dynamics", "texts")
   dxf.save("test.dxf")
