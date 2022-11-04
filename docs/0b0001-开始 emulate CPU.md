我们来仿真一个 **CPU**，其实主要工作就是仿真一个 **CPU** 的指令。

### 6502 指令

开始仿真 CPU 之前，先祭出这个网站，这个网站把 6502 的指令基本都描述了一下([6502 Reference](https://www.nesdev.org/obelisk-6502-guide/reference.html))
通过点击对应的指令，可以锚点到对应的介绍。

<img style="width: 60%; height: 60%;" src="https://mdzz.wiki/usr/uploads/2022/10/3360614534.png" alt="instruction-reference" />

我们可以看到图上有很多指令，其实 NES 有很多非官方指令，不过不要慌，我们把这些指令仿真先，后续考虑处理非官方的一些指令。

### 描述 CPU

现在先写个 **CPU** 的 class/struct，**Swift** 的 class 是引用类型，而 struct 是值类型，这里看个人的喜好，我直接用 class 来声明。

```swift
class CPU {
  var a: UInt8 = 0 // 累加寄存器 a
  var x: UInt8 = 0 // 变址寄存器 x
  var y: UInt8 = 0 // 变址寄存器 y
  var status: UInt8 = 0 // 状态寄存器
  var sp: UInt8 = 0 // 堆栈指针
  var pc: UInt16 = 0 // 程序计数器
}
```
- 寄存器 a 是比较常用的，主要用于读写数据，进行一些逻辑运算
- 寄存器 x 跟 a 差不多，但是它可以更方便 +/- 1，主要用于数据传输、运算等操作
- 寄存器 y 性质跟 x 类似
- 状态寄存器主要保存指令执行时的状态信息，这块有多个状态，分别是 C、Z、I、D、B、V、N，后面写代码会用到
- 堆栈的指针指向一块栈内存这个后面实现的时候展开
- 程序计数器，其实可以理解成一个数组的下标索引，它的寻址范围可以从 0x0000 到 0xFFFF，CPU 根据 pc 找到对应的存储单元，pc 可以自动加 1，CPU 每次读取一条指令，pc 就会自动加 1，当然我们也可以让它跳转返回来改变执行顺序

#### BRK

现在把 **CPU** 做为一个整体，用它来读取“程序”，首先实现一下 **BRK** 指令，通过上面那个网址查表，我们发现 **BRK** 是 `$00`(也就是 0x00，`$` 表示 16 进制)，它的 **Addressing Mode**(地址模式) 是 **Implied**，先不管那么多，直接执行到 **BRK** 让它跳出循环，如果要真实仿真 **BRK** 指令，需要把中断的模式都仿真完整，图简单直接 **return** 吧。

```swift
extension CPU {
  func interpret(program: [UInt8]) {
    pc = 0
    while true {
      let code = program[Int(pc)]
      pc += 1
      switch code {
        case 0x00:
          return
        default:
          break
      }
    }
  }
}
```

目前来看，这好无聊。

#### LDA

我们再来把另一个 **LDA** 实现一下，查表得到 **LDA** 有多个地址模式，**Immediate**，**Zero Page**，**Zero Page X**，**Absolute X**……一个一个来，先把快速模式(**Immediate**)解决掉，这个 Opcode 是 0xa9，此外还要修改 status，这里分别对 Zero Flag 跟 Negative Flag 有影响(Zero Flag 就是上面讲到得 Z，Negative Flag 就是上面讲到的 N)。

<img style="width: 60%; height: 60%;" src="https://mdzz.wiki/usr/uploads/2022/10/1658942244.png" alt="lda" />

```swift
extension CPU {
  func interpret(program: [UInt8]) {
    pc = 0
    while true {
      let code = program[Int(pc)]
      pc += 1
      switch code {
        // ...
        case 0xa9:
          let param = program[Int(pc)]
          pc += 1
          a = param
          // 处理 Zero Flag
          if a == 0 {
            status |= 0b0000_0010
          } else {
            status &= (~0b0000_0010)
          }
          // 处理 Negative Flag
          if a >> 7 == 1 {
            status |= 0b1000_0000
          } else {
            status &= (~0b1000_0000)
          }
        default:
          break
      }
    }
  }
}
```

现在已经把 **Immediate** 模式的 **LDA** 处理脱，还有其他 0xa5、0xb5……这些，尝试动手处理一下。

#### 测试用例

由于我建项目的时候，启用了测试 target，可以写点代码测试一下我们实现的指令，为了方便测试，我们实现一个 `reset` 函数

```swift
extension CPU {
  func reset() {
    a = 0
    x = 0
    y = 0
    status = 0
    sp = 0
    pc = 0
  }
}
```

然后在测试 target 里写上测试的函数，跑一下

```swift
func testSth() {
  let cpu = CPU()
  cpu.interpret(program: [0xa9, 0x00, 0x00])
  assert(cpu.status & 0b0000_0010 == 0b10)
 
  cpu.reset()
  cpu.interpret(program: [0xa9, 0x05, 0x00])
  assert(cpu.a == 0x05)
  assert(cpu.status & 0b0000_0010 == 0)
  assert(cpu.status & 0b1000_0000 == 0)
}
```

----

现在我们已经稍微了解了一挨挨仿真指令的处理方式，后面一节我们继续来优化当前的这些代码。
