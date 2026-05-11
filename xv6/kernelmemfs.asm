
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 7f 19 80       	mov    $0x80197f80,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 67 33 10 80       	mov    $0x80103367,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 00 a1 10 80       	push   $0x8010a100
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 6b 47 00 00       	call   801047e9 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 07 a1 10 80       	push   $0x8010a107
801000c2:	50                   	push   %eax
801000c3:	e8 c4 45 00 00       	call   8010468c <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave
801000f2:	c3                   	ret

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 05 47 00 00       	call   8010480b <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 34 47 00 00       	call   80104879 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 71 45 00 00       	call   801046c8 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 b3 46 00 00       	call   80104879 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 f0 44 00 00       	call   801046c8 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 0e a1 10 80       	push   $0x8010a10e
801001fa:	e8 c2 03 00 00       	call   801005c1 <panic>
}
801001ff:	c9                   	leave
80100200:	c3                   	ret

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 dc 9d 00 00       	call   8010a00e <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave
80100239:	c3                   	ret

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 2b 45 00 00       	call   8010477a <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 1f a1 10 80       	push   $0x8010a11f
8010025e:	e8 5e 03 00 00       	call   801005c1 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 91 9d 00 00       	call   8010a00e <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave
80100282:	c3                   	ret

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 e2 44 00 00       	call   8010477a <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 26 a1 10 80       	push   $0x8010a126
801002a7:	e8 15 03 00 00       	call   801005c1 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 71 44 00 00       	call   8010472c <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 40 45 00 00       	call   8010480b <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 3e 45 00 00       	call   80104879 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave
80100340:	c3                   	ret

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 a3 03 00 00       	call   80100786 <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave
801003f3:	c3                   	ret

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 f6 43 00 00       	call   8010480b <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 30 a1 10 80       	push   $0x8010a130
80100427:	e8 95 01 00 00       	call   801005c1 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 47 01 00 00       	jmp    80100585 <cprintf+0x191>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 37 03 00 00       	call   80100786 <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 2a 01 00 00       	jmp    80100581 <cprintf+0x18d>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 2c 01 00 00    	je     801005a7 <cprintf+0x1b3>
      break;
    switch(c){
8010047b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047f:	0f 84 d1 00 00 00    	je     80100556 <cprintf+0x162>
80100485:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100489:	0f 8c d6 00 00 00    	jl     80100565 <cprintf+0x171>
8010048f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100493:	0f 8f cc 00 00 00    	jg     80100565 <cprintf+0x171>
80100499:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
8010049d:	0f 8c c2 00 00 00    	jl     80100565 <cprintf+0x171>
801004a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801004a6:	83 e8 63             	sub    $0x63,%eax
801004a9:	83 f8 15             	cmp    $0x15,%eax
801004ac:	0f 87 b3 00 00 00    	ja     80100565 <cprintf+0x171>
801004b2:	8b 04 85 40 a1 10 80 	mov    -0x7fef5ec0(,%eax,4),%eax
801004b9:	ff e0                	jmp    *%eax
    //추가
    case 'c':
      consputc(*argp++);
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	83 ec 0c             	sub    $0xc,%esp
801004c9:	50                   	push   %eax
801004ca:	e8 b7 02 00 00       	call   80100786 <consputc>
801004cf:	83 c4 10             	add    $0x10,%esp
      break;
801004d2:	e9 aa 00 00 00       	jmp    80100581 <cprintf+0x18d>
    case 'd':
      printint(*argp++, 10, 1);
801004d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004da:	8d 50 04             	lea    0x4(%eax),%edx
801004dd:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e0:	8b 00                	mov    (%eax),%eax
801004e2:	83 ec 04             	sub    $0x4,%esp
801004e5:	6a 01                	push   $0x1
801004e7:	6a 0a                	push   $0xa
801004e9:	50                   	push   %eax
801004ea:	e8 59 fe ff ff       	call   80100348 <printint>
801004ef:	83 c4 10             	add    $0x10,%esp
      break;
801004f2:	e9 8a 00 00 00       	jmp    80100581 <cprintf+0x18d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004fa:	8d 50 04             	lea    0x4(%eax),%edx
801004fd:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100500:	8b 00                	mov    (%eax),%eax
80100502:	83 ec 04             	sub    $0x4,%esp
80100505:	6a 00                	push   $0x0
80100507:	6a 10                	push   $0x10
80100509:	50                   	push   %eax
8010050a:	e8 39 fe ff ff       	call   80100348 <printint>
8010050f:	83 c4 10             	add    $0x10,%esp
      break;
80100512:	eb 6d                	jmp    80100581 <cprintf+0x18d>
    case 's':
      if((s = (char*)*argp++) == 0)
80100514:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100517:	8d 50 04             	lea    0x4(%eax),%edx
8010051a:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010051d:	8b 00                	mov    (%eax),%eax
8010051f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100522:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80100526:	75 22                	jne    8010054a <cprintf+0x156>
        s = "(null)";
80100528:	c7 45 ec 39 a1 10 80 	movl   $0x8010a139,-0x14(%ebp)
      for(; *s; s++)
8010052f:	eb 19                	jmp    8010054a <cprintf+0x156>
        consputc(*s);
80100531:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100534:	0f b6 00             	movzbl (%eax),%eax
80100537:	0f be c0             	movsbl %al,%eax
8010053a:	83 ec 0c             	sub    $0xc,%esp
8010053d:	50                   	push   %eax
8010053e:	e8 43 02 00 00       	call   80100786 <consputc>
80100543:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
80100546:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
8010054a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010054d:	0f b6 00             	movzbl (%eax),%eax
80100550:	84 c0                	test   %al,%al
80100552:	75 dd                	jne    80100531 <cprintf+0x13d>
      break;
80100554:	eb 2b                	jmp    80100581 <cprintf+0x18d>
    case '%':
      consputc('%');
80100556:	83 ec 0c             	sub    $0xc,%esp
80100559:	6a 25                	push   $0x25
8010055b:	e8 26 02 00 00       	call   80100786 <consputc>
80100560:	83 c4 10             	add    $0x10,%esp
      break;
80100563:	eb 1c                	jmp    80100581 <cprintf+0x18d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100565:	83 ec 0c             	sub    $0xc,%esp
80100568:	6a 25                	push   $0x25
8010056a:	e8 17 02 00 00       	call   80100786 <consputc>
8010056f:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100572:	83 ec 0c             	sub    $0xc,%esp
80100575:	ff 75 e4             	push   -0x1c(%ebp)
80100578:	e8 09 02 00 00       	call   80100786 <consputc>
8010057d:	83 c4 10             	add    $0x10,%esp
      break;
80100580:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100581:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100585:	8b 55 08             	mov    0x8(%ebp),%edx
80100588:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010058b:	01 d0                	add    %edx,%eax
8010058d:	0f b6 00             	movzbl (%eax),%eax
80100590:	0f be c0             	movsbl %al,%eax
80100593:	25 ff 00 00 00       	and    $0xff,%eax
80100598:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010059b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010059f:	0f 85 99 fe ff ff    	jne    8010043e <cprintf+0x4a>
801005a5:	eb 01                	jmp    801005a8 <cprintf+0x1b4>
      break;
801005a7:	90                   	nop
    }
  }

  if(locking)
801005a8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801005ac:	74 10                	je     801005be <cprintf+0x1ca>
    release(&cons.lock);
801005ae:	83 ec 0c             	sub    $0xc,%esp
801005b1:	68 00 1a 19 80       	push   $0x80191a00
801005b6:	e8 be 42 00 00       	call   80104879 <release>
801005bb:	83 c4 10             	add    $0x10,%esp
}
801005be:	90                   	nop
801005bf:	c9                   	leave
801005c0:	c3                   	ret

801005c1 <panic>:

void
panic(char *s)
{
801005c1:	55                   	push   %ebp
801005c2:	89 e5                	mov    %esp,%ebp
801005c4:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005c7:	e8 75 fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005cc:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005d3:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005d6:	e8 21 25 00 00       	call   80102afc <lapicid>
801005db:	83 ec 08             	sub    $0x8,%esp
801005de:	50                   	push   %eax
801005df:	68 98 a1 10 80       	push   $0x8010a198
801005e4:	e8 0b fe ff ff       	call   801003f4 <cprintf>
801005e9:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005ec:	8b 45 08             	mov    0x8(%ebp),%eax
801005ef:	83 ec 0c             	sub    $0xc,%esp
801005f2:	50                   	push   %eax
801005f3:	e8 fc fd ff ff       	call   801003f4 <cprintf>
801005f8:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005fb:	83 ec 0c             	sub    $0xc,%esp
801005fe:	68 ac a1 10 80       	push   $0x8010a1ac
80100603:	e8 ec fd ff ff       	call   801003f4 <cprintf>
80100608:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
8010060b:	83 ec 08             	sub    $0x8,%esp
8010060e:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100611:	50                   	push   %eax
80100612:	8d 45 08             	lea    0x8(%ebp),%eax
80100615:	50                   	push   %eax
80100616:	e8 b0 42 00 00       	call   801048cb <getcallerpcs>
8010061b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010061e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100625:	eb 1c                	jmp    80100643 <panic+0x82>
    cprintf(" %p", pcs[i]);
80100627:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010062a:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
8010062e:	83 ec 08             	sub    $0x8,%esp
80100631:	50                   	push   %eax
80100632:	68 ae a1 10 80       	push   $0x8010a1ae
80100637:	e8 b8 fd ff ff       	call   801003f4 <cprintf>
8010063c:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
8010063f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100643:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100647:	7e de                	jle    80100627 <panic+0x66>
  panicked = 1; // freeze other CPU
80100649:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100650:	00 00 00 
  for(;;)
80100653:	90                   	nop
80100654:	eb fd                	jmp    80100653 <panic+0x92>

80100656 <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
80100656:	55                   	push   %ebp
80100657:	89 e5                	mov    %esp,%ebp
80100659:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
8010065c:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100660:	75 64                	jne    801006c6 <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
80100662:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100668:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010066d:	89 c8                	mov    %ecx,%eax
8010066f:	f7 ea                	imul   %edx
80100671:	89 d0                	mov    %edx,%eax
80100673:	c1 f8 04             	sar    $0x4,%eax
80100676:	89 ca                	mov    %ecx,%edx
80100678:	c1 fa 1f             	sar    $0x1f,%edx
8010067b:	29 d0                	sub    %edx,%eax
8010067d:	6b d0 35             	imul   $0x35,%eax,%edx
80100680:	89 c8                	mov    %ecx,%eax
80100682:	29 d0                	sub    %edx,%eax
80100684:	ba 35 00 00 00       	mov    $0x35,%edx
80100689:	29 c2                	sub    %eax,%edx
8010068b:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100690:	01 d0                	add    %edx,%eax
80100692:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
80100697:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010069c:	3d 23 04 00 00       	cmp    $0x423,%eax
801006a1:	0f 8e dc 00 00 00    	jle    80100783 <graphic_putc+0x12d>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006a7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ac:	83 e8 35             	sub    $0x35,%eax
801006af:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006b4:	83 ec 0c             	sub    $0xc,%esp
801006b7:	6a 1e                	push   $0x1e
801006b9:	e8 bd 78 00 00       	call   80107f7b <graphic_scroll_up>
801006be:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006c1:	e9 bd 00 00 00       	jmp    80100783 <graphic_putc+0x12d>
  }else if(c == BACKSPACE){
801006c6:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006cd:	75 1f                	jne    801006ee <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006cf:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006d4:	85 c0                	test   %eax,%eax
801006d6:	0f 8e a7 00 00 00    	jle    80100783 <graphic_putc+0x12d>
801006dc:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e1:	83 e8 01             	sub    $0x1,%eax
801006e4:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006e9:	e9 95 00 00 00       	jmp    80100783 <graphic_putc+0x12d>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006ee:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006f3:	3d 23 04 00 00       	cmp    $0x423,%eax
801006f8:	7e 1a                	jle    80100714 <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006fa:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006ff:	83 e8 35             	sub    $0x35,%eax
80100702:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
80100707:	83 ec 0c             	sub    $0xc,%esp
8010070a:	6a 1e                	push   $0x1e
8010070c:	e8 6a 78 00 00       	call   80107f7b <graphic_scroll_up>
80100711:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
80100714:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
8010071a:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010071f:	89 c8                	mov    %ecx,%eax
80100721:	f7 ea                	imul   %edx
80100723:	89 d0                	mov    %edx,%eax
80100725:	c1 f8 04             	sar    $0x4,%eax
80100728:	89 ca                	mov    %ecx,%edx
8010072a:	c1 fa 1f             	sar    $0x1f,%edx
8010072d:	29 d0                	sub    %edx,%eax
8010072f:	6b d0 35             	imul   $0x35,%eax,%edx
80100732:	89 c8                	mov    %ecx,%eax
80100734:	29 d0                	sub    %edx,%eax
80100736:	89 c2                	mov    %eax,%edx
80100738:	c1 e2 04             	shl    $0x4,%edx
8010073b:	29 c2                	sub    %eax,%edx
8010073d:	8d 42 02             	lea    0x2(%edx),%eax
80100740:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
80100743:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100749:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
8010074e:	89 c8                	mov    %ecx,%eax
80100750:	f7 ea                	imul   %edx
80100752:	c1 fa 04             	sar    $0x4,%edx
80100755:	89 c8                	mov    %ecx,%eax
80100757:	c1 f8 1f             	sar    $0x1f,%eax
8010075a:	29 c2                	sub    %eax,%edx
8010075c:	6b c2 1e             	imul   $0x1e,%edx,%eax
8010075f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
80100762:	83 ec 04             	sub    $0x4,%esp
80100765:	ff 75 08             	push   0x8(%ebp)
80100768:	ff 75 f0             	push   -0x10(%ebp)
8010076b:	ff 75 f4             	push   -0xc(%ebp)
8010076e:	e8 75 78 00 00       	call   80107fe8 <font_render>
80100773:	83 c4 10             	add    $0x10,%esp
    console_pos++;
80100776:	a1 00 d0 10 80       	mov    0x8010d000,%eax
8010077b:	83 c0 01             	add    $0x1,%eax
8010077e:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
80100783:	90                   	nop
80100784:	c9                   	leave
80100785:	c3                   	ret

80100786 <consputc>:


void
consputc(int c)
{
80100786:	55                   	push   %ebp
80100787:	89 e5                	mov    %esp,%ebp
80100789:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010078c:	a1 ec 19 19 80       	mov    0x801919ec,%eax
80100791:	85 c0                	test   %eax,%eax
80100793:	74 08                	je     8010079d <consputc+0x17>
    cli();
80100795:	e8 a7 fb ff ff       	call   80100341 <cli>
    for(;;)
8010079a:	90                   	nop
8010079b:	eb fd                	jmp    8010079a <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
8010079d:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007a4:	75 29                	jne    801007cf <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007a6:	83 ec 0c             	sub    $0xc,%esp
801007a9:	6a 08                	push   $0x8
801007ab:	e8 59 5c 00 00       	call   80106409 <uartputc>
801007b0:	83 c4 10             	add    $0x10,%esp
801007b3:	83 ec 0c             	sub    $0xc,%esp
801007b6:	6a 20                	push   $0x20
801007b8:	e8 4c 5c 00 00       	call   80106409 <uartputc>
801007bd:	83 c4 10             	add    $0x10,%esp
801007c0:	83 ec 0c             	sub    $0xc,%esp
801007c3:	6a 08                	push   $0x8
801007c5:	e8 3f 5c 00 00       	call   80106409 <uartputc>
801007ca:	83 c4 10             	add    $0x10,%esp
801007cd:	eb 0e                	jmp    801007dd <consputc+0x57>
  } else {
    uartputc(c);
801007cf:	83 ec 0c             	sub    $0xc,%esp
801007d2:	ff 75 08             	push   0x8(%ebp)
801007d5:	e8 2f 5c 00 00       	call   80106409 <uartputc>
801007da:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007dd:	83 ec 0c             	sub    $0xc,%esp
801007e0:	ff 75 08             	push   0x8(%ebp)
801007e3:	e8 6e fe ff ff       	call   80100656 <graphic_putc>
801007e8:	83 c4 10             	add    $0x10,%esp
}
801007eb:	90                   	nop
801007ec:	c9                   	leave
801007ed:	c3                   	ret

801007ee <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007ee:	55                   	push   %ebp
801007ef:	89 e5                	mov    %esp,%ebp
801007f1:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007fb:	83 ec 0c             	sub    $0xc,%esp
801007fe:	68 00 1a 19 80       	push   $0x80191a00
80100803:	e8 03 40 00 00       	call   8010480b <acquire>
80100808:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
8010080b:	e9 58 01 00 00       	jmp    80100968 <consoleintr+0x17a>
    switch(c){
80100810:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100814:	0f 84 81 00 00 00    	je     8010089b <consoleintr+0xad>
8010081a:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010081e:	0f 8f ac 00 00 00    	jg     801008d0 <consoleintr+0xe2>
80100824:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100828:	74 43                	je     8010086d <consoleintr+0x7f>
8010082a:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010082e:	0f 8f 9c 00 00 00    	jg     801008d0 <consoleintr+0xe2>
80100834:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100838:	74 61                	je     8010089b <consoleintr+0xad>
8010083a:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010083e:	0f 85 8c 00 00 00    	jne    801008d0 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100844:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
8010084b:	e9 18 01 00 00       	jmp    80100968 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100850:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100855:	83 e8 01             	sub    $0x1,%eax
80100858:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
8010085d:	83 ec 0c             	sub    $0xc,%esp
80100860:	68 00 01 00 00       	push   $0x100
80100865:	e8 1c ff ff ff       	call   80100786 <consputc>
8010086a:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010086d:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100873:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100878:	39 c2                	cmp    %eax,%edx
8010087a:	0f 84 e1 00 00 00    	je     80100961 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100880:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100885:	83 e8 01             	sub    $0x1,%eax
80100888:	83 e0 7f             	and    $0x7f,%eax
8010088b:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
80100892:	3c 0a                	cmp    $0xa,%al
80100894:	75 ba                	jne    80100850 <consoleintr+0x62>
      }
      break;
80100896:	e9 c6 00 00 00       	jmp    80100961 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
8010089b:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008a1:	a1 e4 19 19 80       	mov    0x801919e4,%eax
801008a6:	39 c2                	cmp    %eax,%edx
801008a8:	0f 84 b6 00 00 00    	je     80100964 <consoleintr+0x176>
        input.e--;
801008ae:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008b3:	83 e8 01             	sub    $0x1,%eax
801008b6:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008bb:	83 ec 0c             	sub    $0xc,%esp
801008be:	68 00 01 00 00       	push   $0x100
801008c3:	e8 be fe ff ff       	call   80100786 <consputc>
801008c8:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008cb:	e9 94 00 00 00       	jmp    80100964 <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008d0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008d4:	0f 84 8d 00 00 00    	je     80100967 <consoleintr+0x179>
801008da:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008e0:	a1 e0 19 19 80       	mov    0x801919e0,%eax
801008e5:	29 c2                	sub    %eax,%edx
801008e7:	83 fa 7f             	cmp    $0x7f,%edx
801008ea:	77 7b                	ja     80100967 <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
801008ec:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008f0:	74 05                	je     801008f7 <consoleintr+0x109>
801008f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008f5:	eb 05                	jmp    801008fc <consoleintr+0x10e>
801008f7:	b8 0a 00 00 00       	mov    $0xa,%eax
801008fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008ff:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100904:	8d 50 01             	lea    0x1(%eax),%edx
80100907:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
8010090d:	83 e0 7f             	and    $0x7f,%eax
80100910:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100913:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100919:	83 ec 0c             	sub    $0xc,%esp
8010091c:	ff 75 f0             	push   -0x10(%ebp)
8010091f:	e8 62 fe ff ff       	call   80100786 <consputc>
80100924:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100927:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
8010092b:	74 18                	je     80100945 <consoleintr+0x157>
8010092d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100931:	74 12                	je     80100945 <consoleintr+0x157>
80100933:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100939:	a1 e0 19 19 80       	mov    0x801919e0,%eax
8010093e:	83 e8 80             	sub    $0xffffff80,%eax
80100941:	39 c2                	cmp    %eax,%edx
80100943:	75 22                	jne    80100967 <consoleintr+0x179>
          input.w = input.e;
80100945:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010094a:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e0 19 19 80       	push   $0x801919e0
80100957:	e8 64 3a 00 00       	call   801043c0 <wakeup>
8010095c:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010095f:	eb 06                	jmp    80100967 <consoleintr+0x179>
      break;
80100961:	90                   	nop
80100962:	eb 04                	jmp    80100968 <consoleintr+0x17a>
      break;
80100964:	90                   	nop
80100965:	eb 01                	jmp    80100968 <consoleintr+0x17a>
      break;
80100967:	90                   	nop
  while((c = getc()) >= 0){
80100968:	8b 45 08             	mov    0x8(%ebp),%eax
8010096b:	ff d0                	call   *%eax
8010096d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100970:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100974:	0f 89 96 fe ff ff    	jns    80100810 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
8010097a:	83 ec 0c             	sub    $0xc,%esp
8010097d:	68 00 1a 19 80       	push   $0x80191a00
80100982:	e8 f2 3e 00 00       	call   80104879 <release>
80100987:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
8010098a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010098e:	74 05                	je     80100995 <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100990:	e8 e6 3a 00 00       	call   8010447b <procdump>
  }
}
80100995:	90                   	nop
80100996:	c9                   	leave
80100997:	c3                   	ret

80100998 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100998:	55                   	push   %ebp
80100999:	89 e5                	mov    %esp,%ebp
8010099b:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010099e:	83 ec 0c             	sub    $0xc,%esp
801009a1:	ff 75 08             	push   0x8(%ebp)
801009a4:	e8 5c 11 00 00       	call   80101b05 <iunlock>
801009a9:	83 c4 10             	add    $0x10,%esp
  target = n;
801009ac:	8b 45 10             	mov    0x10(%ebp),%eax
801009af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009b2:	83 ec 0c             	sub    $0xc,%esp
801009b5:	68 00 1a 19 80       	push   $0x80191a00
801009ba:	e8 4c 3e 00 00       	call   8010480b <acquire>
801009bf:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009c2:	e9 ab 00 00 00       	jmp    80100a72 <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009c7:	e8 64 30 00 00       	call   80103a30 <myproc>
801009cc:	8b 40 24             	mov    0x24(%eax),%eax
801009cf:	85 c0                	test   %eax,%eax
801009d1:	74 28                	je     801009fb <consoleread+0x63>
        release(&cons.lock);
801009d3:	83 ec 0c             	sub    $0xc,%esp
801009d6:	68 00 1a 19 80       	push   $0x80191a00
801009db:	e8 99 3e 00 00       	call   80104879 <release>
801009e0:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009e3:	83 ec 0c             	sub    $0xc,%esp
801009e6:	ff 75 08             	push   0x8(%ebp)
801009e9:	e8 04 10 00 00       	call   801019f2 <ilock>
801009ee:	83 c4 10             	add    $0x10,%esp
        return -1;
801009f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009f6:	e9 ab 00 00 00       	jmp    80100aa6 <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
801009fb:	83 ec 08             	sub    $0x8,%esp
801009fe:	68 00 1a 19 80       	push   $0x80191a00
80100a03:	68 e0 19 19 80       	push   $0x801919e0
80100a08:	e8 cc 38 00 00       	call   801042d9 <sleep>
80100a0d:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a10:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
80100a16:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100a1b:	39 c2                	cmp    %eax,%edx
80100a1d:	74 a8                	je     801009c7 <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a1f:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a24:	8d 50 01             	lea    0x1(%eax),%edx
80100a27:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a2d:	83 e0 7f             	and    $0x7f,%eax
80100a30:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a37:	0f be c0             	movsbl %al,%eax
80100a3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a3d:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a41:	75 17                	jne    80100a5a <consoleread+0xc2>
      if(n < target){
80100a43:	8b 45 10             	mov    0x10(%ebp),%eax
80100a46:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a49:	73 2f                	jae    80100a7a <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a4b:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a50:	83 e8 01             	sub    $0x1,%eax
80100a53:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a58:	eb 20                	jmp    80100a7a <consoleread+0xe2>
    }
    *dst++ = c;
80100a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a5d:	8d 50 01             	lea    0x1(%eax),%edx
80100a60:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a63:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a66:	88 10                	mov    %dl,(%eax)
    --n;
80100a68:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a6c:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a70:	74 0b                	je     80100a7d <consoleread+0xe5>
  while(n > 0){
80100a72:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a76:	7f 98                	jg     80100a10 <consoleread+0x78>
80100a78:	eb 04                	jmp    80100a7e <consoleread+0xe6>
      break;
80100a7a:	90                   	nop
80100a7b:	eb 01                	jmp    80100a7e <consoleread+0xe6>
      break;
80100a7d:	90                   	nop
  }
  release(&cons.lock);
80100a7e:	83 ec 0c             	sub    $0xc,%esp
80100a81:	68 00 1a 19 80       	push   $0x80191a00
80100a86:	e8 ee 3d 00 00       	call   80104879 <release>
80100a8b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a8e:	83 ec 0c             	sub    $0xc,%esp
80100a91:	ff 75 08             	push   0x8(%ebp)
80100a94:	e8 59 0f 00 00       	call   801019f2 <ilock>
80100a99:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a9c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa2:	29 c2                	sub    %eax,%edx
80100aa4:	89 d0                	mov    %edx,%eax
}
80100aa6:	c9                   	leave
80100aa7:	c3                   	ret

80100aa8 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100aa8:	55                   	push   %ebp
80100aa9:	89 e5                	mov    %esp,%ebp
80100aab:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	ff 75 08             	push   0x8(%ebp)
80100ab4:	e8 4c 10 00 00       	call   80101b05 <iunlock>
80100ab9:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100abc:	83 ec 0c             	sub    $0xc,%esp
80100abf:	68 00 1a 19 80       	push   $0x80191a00
80100ac4:	e8 42 3d 00 00       	call   8010480b <acquire>
80100ac9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100acc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100ad3:	eb 21                	jmp    80100af6 <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100ad5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ad8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100adb:	01 d0                	add    %edx,%eax
80100add:	0f b6 00             	movzbl (%eax),%eax
80100ae0:	0f be c0             	movsbl %al,%eax
80100ae3:	0f b6 c0             	movzbl %al,%eax
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	50                   	push   %eax
80100aea:	e8 97 fc ff ff       	call   80100786 <consputc>
80100aef:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100af9:	3b 45 10             	cmp    0x10(%ebp),%eax
80100afc:	7c d7                	jl     80100ad5 <consolewrite+0x2d>
  release(&cons.lock);
80100afe:	83 ec 0c             	sub    $0xc,%esp
80100b01:	68 00 1a 19 80       	push   $0x80191a00
80100b06:	e8 6e 3d 00 00       	call   80104879 <release>
80100b0b:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b0e:	83 ec 0c             	sub    $0xc,%esp
80100b11:	ff 75 08             	push   0x8(%ebp)
80100b14:	e8 d9 0e 00 00       	call   801019f2 <ilock>
80100b19:	83 c4 10             	add    $0x10,%esp

  return n;
80100b1c:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b1f:	c9                   	leave
80100b20:	c3                   	ret

80100b21 <consoleinit>:

void
consoleinit(void)
{
80100b21:	55                   	push   %ebp
80100b22:	89 e5                	mov    %esp,%ebp
80100b24:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b27:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b2e:	00 00 00 
  initlock(&cons.lock, "console");
80100b31:	83 ec 08             	sub    $0x8,%esp
80100b34:	68 b2 a1 10 80       	push   $0x8010a1b2
80100b39:	68 00 1a 19 80       	push   $0x80191a00
80100b3e:	e8 a6 3c 00 00       	call   801047e9 <initlock>
80100b43:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b46:	c7 05 4c 1a 19 80 a8 	movl   $0x80100aa8,0x80191a4c
80100b4d:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b50:	c7 05 48 1a 19 80 98 	movl   $0x80100998,0x80191a48
80100b57:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b5a:	c7 45 f4 ba a1 10 80 	movl   $0x8010a1ba,-0xc(%ebp)
80100b61:	eb 19                	jmp    80100b7c <consoleinit+0x5b>
    graphic_putc(*p);
80100b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b66:	0f b6 00             	movzbl (%eax),%eax
80100b69:	0f be c0             	movsbl %al,%eax
80100b6c:	83 ec 0c             	sub    $0xc,%esp
80100b6f:	50                   	push   %eax
80100b70:	e8 e1 fa ff ff       	call   80100656 <graphic_putc>
80100b75:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b78:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b7f:	0f b6 00             	movzbl (%eax),%eax
80100b82:	84 c0                	test   %al,%al
80100b84:	75 dd                	jne    80100b63 <consoleinit+0x42>
  
  cons.locking = 1;
80100b86:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b8d:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b90:	83 ec 08             	sub    $0x8,%esp
80100b93:	6a 00                	push   $0x0
80100b95:	6a 01                	push   $0x1
80100b97:	e8 9a 1a 00 00       	call   80102636 <ioapicenable>
80100b9c:	83 c4 10             	add    $0x10,%esp
}
80100b9f:	90                   	nop
80100ba0:	c9                   	leave
80100ba1:	c3                   	ret

80100ba2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ba2:	55                   	push   %ebp
80100ba3:	89 e5                	mov    %esp,%ebp
80100ba5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100bab:	e8 80 2e 00 00       	call   80103a30 <myproc>
80100bb0:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100bb3:	e8 86 24 00 00       	call   8010303e <begin_op>

  if((ip = namei(path)) == 0){
80100bb8:	83 ec 0c             	sub    $0xc,%esp
80100bbb:	ff 75 08             	push   0x8(%ebp)
80100bbe:	e8 62 19 00 00       	call   80102525 <namei>
80100bc3:	83 c4 10             	add    $0x10,%esp
80100bc6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bc9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bcd:	75 1f                	jne    80100bee <exec+0x4c>
    end_op();
80100bcf:	e8 f6 24 00 00       	call   801030ca <end_op>
    cprintf("exec: fail\n");
80100bd4:	83 ec 0c             	sub    $0xc,%esp
80100bd7:	68 d0 a1 10 80       	push   $0x8010a1d0
80100bdc:	e8 13 f8 ff ff       	call   801003f4 <cprintf>
80100be1:	83 c4 10             	add    $0x10,%esp
    return -1;
80100be4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100be9:	e9 d9 03 00 00       	jmp    80100fc7 <exec+0x425>
  }
  ilock(ip);
80100bee:	83 ec 0c             	sub    $0xc,%esp
80100bf1:	ff 75 d8             	push   -0x28(%ebp)
80100bf4:	e8 f9 0d 00 00       	call   801019f2 <ilock>
80100bf9:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100bfc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c03:	6a 34                	push   $0x34
80100c05:	6a 00                	push   $0x0
80100c07:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c0d:	50                   	push   %eax
80100c0e:	ff 75 d8             	push   -0x28(%ebp)
80100c11:	e8 c8 12 00 00       	call   80101ede <readi>
80100c16:	83 c4 10             	add    $0x10,%esp
80100c19:	83 f8 34             	cmp    $0x34,%eax
80100c1c:	0f 85 4e 03 00 00    	jne    80100f70 <exec+0x3ce>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c22:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c28:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c2d:	0f 85 40 03 00 00    	jne    80100f73 <exec+0x3d1>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c33:	e8 cd 67 00 00       	call   80107405 <setupkvm>
80100c38:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c3b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c3f:	0f 84 31 03 00 00    	je     80100f76 <exec+0x3d4>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c45:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c4c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c53:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c59:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c5c:	e9 de 00 00 00       	jmp    80100d3f <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c61:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c64:	6a 20                	push   $0x20
80100c66:	50                   	push   %eax
80100c67:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c6d:	50                   	push   %eax
80100c6e:	ff 75 d8             	push   -0x28(%ebp)
80100c71:	e8 68 12 00 00       	call   80101ede <readi>
80100c76:	83 c4 10             	add    $0x10,%esp
80100c79:	83 f8 20             	cmp    $0x20,%eax
80100c7c:	0f 85 f7 02 00 00    	jne    80100f79 <exec+0x3d7>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c82:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c88:	83 f8 01             	cmp    $0x1,%eax
80100c8b:	0f 85 a0 00 00 00    	jne    80100d31 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c91:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c97:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c9d:	39 c2                	cmp    %eax,%edx
80100c9f:	0f 82 d7 02 00 00    	jb     80100f7c <exec+0x3da>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100ca5:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cab:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cb1:	01 c2                	add    %eax,%edx
80100cb3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cb9:	39 c2                	cmp    %eax,%edx
80100cbb:	0f 82 be 02 00 00    	jb     80100f7f <exec+0x3dd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100cc1:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100cc7:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100ccd:	01 d0                	add    %edx,%eax
80100ccf:	83 ec 04             	sub    $0x4,%esp
80100cd2:	50                   	push   %eax
80100cd3:	ff 75 e0             	push   -0x20(%ebp)
80100cd6:	ff 75 d4             	push   -0x2c(%ebp)
80100cd9:	e8 21 6b 00 00       	call   801077ff <allocuvm>
80100cde:	83 c4 10             	add    $0x10,%esp
80100ce1:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ce4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100ce8:	0f 84 94 02 00 00    	je     80100f82 <exec+0x3e0>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100cee:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cf4:	25 ff 0f 00 00       	and    $0xfff,%eax
80100cf9:	85 c0                	test   %eax,%eax
80100cfb:	0f 85 84 02 00 00    	jne    80100f85 <exec+0x3e3>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d01:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100d07:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100d0d:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100d13:	83 ec 0c             	sub    $0xc,%esp
80100d16:	52                   	push   %edx
80100d17:	50                   	push   %eax
80100d18:	ff 75 d8             	push   -0x28(%ebp)
80100d1b:	51                   	push   %ecx
80100d1c:	ff 75 d4             	push   -0x2c(%ebp)
80100d1f:	e8 0e 6a 00 00       	call   80107732 <loaduvm>
80100d24:	83 c4 20             	add    $0x20,%esp
80100d27:	85 c0                	test   %eax,%eax
80100d29:	0f 88 59 02 00 00    	js     80100f88 <exec+0x3e6>
80100d2f:	eb 01                	jmp    80100d32 <exec+0x190>
      continue;
80100d31:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d32:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d36:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d39:	83 c0 20             	add    $0x20,%eax
80100d3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d3f:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d46:	0f b7 c0             	movzwl %ax,%eax
80100d49:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d4c:	0f 8c 0f ff ff ff    	jl     80100c61 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d52:	83 ec 0c             	sub    $0xc,%esp
80100d55:	ff 75 d8             	push   -0x28(%ebp)
80100d58:	e8 c6 0e 00 00       	call   80101c23 <iunlockput>
80100d5d:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d60:	e8 65 23 00 00       	call   801030ca <end_op>
  ip = 0;
80100d65:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;*/
  //수정
  sz = KERNBASE-1;
80100d6c:	c7 45 e0 ff ff ff 7f 	movl   $0x7fffffff,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz-PGSIZE, sz)) == 0)
80100d73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d76:	2d 00 10 00 00       	sub    $0x1000,%eax
80100d7b:	83 ec 04             	sub    $0x4,%esp
80100d7e:	ff 75 e0             	push   -0x20(%ebp)
80100d81:	50                   	push   %eax
80100d82:	ff 75 d4             	push   -0x2c(%ebp)
80100d85:	e8 75 6a 00 00       	call   801077ff <allocuvm>
80100d8a:	83 c4 10             	add    $0x10,%esp
80100d8d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d90:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d94:	0f 84 f1 01 00 00    	je     80100f8b <exec+0x3e9>
    goto bad;
  sz=PGROUNDDOWN(0x3000);
80100d9a:	c7 45 e0 00 30 00 00 	movl   $0x3000,-0x20(%ebp)
  sp = KERNBASE-1;
80100da1:	c7 45 dc ff ff ff 7f 	movl   $0x7fffffff,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100daf:	e9 96 00 00 00       	jmp    80100e4a <exec+0x2a8>
    if(argc >= MAXARG)
80100db4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100db8:	0f 87 d0 01 00 00    	ja     80100f8e <exec+0x3ec>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcb:	01 d0                	add    %edx,%eax
80100dcd:	8b 00                	mov    (%eax),%eax
80100dcf:	83 ec 0c             	sub    $0xc,%esp
80100dd2:	50                   	push   %eax
80100dd3:	e8 f7 3e 00 00       	call   80104ccf <strlen>
80100dd8:	83 c4 10             	add    $0x10,%esp
80100ddb:	89 c2                	mov    %eax,%edx
80100ddd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de0:	29 d0                	sub    %edx,%eax
80100de2:	83 e8 01             	sub    $0x1,%eax
80100de5:	83 e0 fc             	and    $0xfffffffc,%eax
80100de8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 d0                	add    %edx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	83 ec 0c             	sub    $0xc,%esp
80100dff:	50                   	push   %eax
80100e00:	e8 ca 3e 00 00       	call   80104ccf <strlen>
80100e05:	83 c4 10             	add    $0x10,%esp
80100e08:	83 c0 01             	add    $0x1,%eax
80100e0b:	89 c1                	mov    %eax,%ecx
80100e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e1a:	01 d0                	add    %edx,%eax
80100e1c:	8b 00                	mov    (%eax),%eax
80100e1e:	51                   	push   %ecx
80100e1f:	50                   	push   %eax
80100e20:	ff 75 dc             	push   -0x24(%ebp)
80100e23:	ff 75 d4             	push   -0x2c(%ebp)
80100e26:	e8 c0 6d 00 00       	call   80107beb <copyout>
80100e2b:	83 c4 10             	add    $0x10,%esp
80100e2e:	85 c0                	test   %eax,%eax
80100e30:	0f 88 5b 01 00 00    	js     80100f91 <exec+0x3ef>
      goto bad;
    ustack[3+argc] = sp;
80100e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e39:	8d 50 03             	lea    0x3(%eax),%edx
80100e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e3f:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e46:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e54:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e57:	01 d0                	add    %edx,%eax
80100e59:	8b 00                	mov    (%eax),%eax
80100e5b:	85 c0                	test   %eax,%eax
80100e5d:	0f 85 51 ff ff ff    	jne    80100db4 <exec+0x212>
  }
  ustack[3+argc] = 0;
80100e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e66:	83 c0 03             	add    $0x3,%eax
80100e69:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e70:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e74:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e7b:	ff ff ff 
  ustack[1] = argc;
80100e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e81:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8a:	83 c0 01             	add    $0x1,%eax
80100e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e94:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e97:	29 d0                	sub    %edx,%eax
80100e99:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea2:	83 c0 04             	add    $0x4,%eax
80100ea5:	c1 e0 02             	shl    $0x2,%eax
80100ea8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eae:	83 c0 04             	add    $0x4,%eax
80100eb1:	c1 e0 02             	shl    $0x2,%eax
80100eb4:	50                   	push   %eax
80100eb5:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ebb:	50                   	push   %eax
80100ebc:	ff 75 dc             	push   -0x24(%ebp)
80100ebf:	ff 75 d4             	push   -0x2c(%ebp)
80100ec2:	e8 24 6d 00 00       	call   80107beb <copyout>
80100ec7:	83 c4 10             	add    $0x10,%esp
80100eca:	85 c0                	test   %eax,%eax
80100ecc:	0f 88 c2 00 00 00    	js     80100f94 <exec+0x3f2>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ede:	eb 17                	jmp    80100ef7 <exec+0x355>
    if(*s == '/')
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	0f b6 00             	movzbl (%eax),%eax
80100ee6:	3c 2f                	cmp    $0x2f,%al
80100ee8:	75 09                	jne    80100ef3 <exec+0x351>
      last = s+1;
80100eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eed:	83 c0 01             	add    $0x1,%eax
80100ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ef3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efa:	0f b6 00             	movzbl (%eax),%eax
80100efd:	84 c0                	test   %al,%al
80100eff:	75 df                	jne    80100ee0 <exec+0x33e>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f04:	83 c0 6c             	add    $0x6c,%eax
80100f07:	83 ec 04             	sub    $0x4,%esp
80100f0a:	6a 10                	push   $0x10
80100f0c:	ff 75 f0             	push   -0x10(%ebp)
80100f0f:	50                   	push   %eax
80100f10:	e8 6f 3d 00 00       	call   80104c84 <safestrcpy>
80100f15:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1b:	8b 40 04             	mov    0x4(%eax),%eax
80100f1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f27:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f30:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f35:	8b 40 18             	mov    0x18(%eax),%eax
80100f38:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f3e:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f41:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f44:	8b 40 18             	mov    0x18(%eax),%eax
80100f47:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f4a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f4d:	83 ec 0c             	sub    $0xc,%esp
80100f50:	ff 75 d0             	push   -0x30(%ebp)
80100f53:	e8 cb 65 00 00       	call   80107523 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 62 6a 00 00       	call   801079c8 <freevm>
80100f66:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f69:	b8 00 00 00 00       	mov    $0x0,%eax
80100f6e:	eb 57                	jmp    80100fc7 <exec+0x425>
    goto bad;
80100f70:	90                   	nop
80100f71:	eb 22                	jmp    80100f95 <exec+0x3f3>
    goto bad;
80100f73:	90                   	nop
80100f74:	eb 1f                	jmp    80100f95 <exec+0x3f3>
    goto bad;
80100f76:	90                   	nop
80100f77:	eb 1c                	jmp    80100f95 <exec+0x3f3>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 19                	jmp    80100f95 <exec+0x3f3>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 16                	jmp    80100f95 <exec+0x3f3>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 13                	jmp    80100f95 <exec+0x3f3>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 10                	jmp    80100f95 <exec+0x3f3>
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 0d                	jmp    80100f95 <exec+0x3f3>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 0a                	jmp    80100f95 <exec+0x3f3>
    goto bad;
80100f8b:	90                   	nop
80100f8c:	eb 07                	jmp    80100f95 <exec+0x3f3>
      goto bad;
80100f8e:	90                   	nop
80100f8f:	eb 04                	jmp    80100f95 <exec+0x3f3>
      goto bad;
80100f91:	90                   	nop
80100f92:	eb 01                	jmp    80100f95 <exec+0x3f3>
    goto bad;
80100f94:	90                   	nop

 bad:
  if(pgdir)
80100f95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f99:	74 0e                	je     80100fa9 <exec+0x407>
    freevm(pgdir);
80100f9b:	83 ec 0c             	sub    $0xc,%esp
80100f9e:	ff 75 d4             	push   -0x2c(%ebp)
80100fa1:	e8 22 6a 00 00       	call   801079c8 <freevm>
80100fa6:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fad:	74 13                	je     80100fc2 <exec+0x420>
    iunlockput(ip);
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	ff 75 d8             	push   -0x28(%ebp)
80100fb5:	e8 69 0c 00 00       	call   80101c23 <iunlockput>
80100fba:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fbd:	e8 08 21 00 00       	call   801030ca <end_op>
  }
  return -1;
80100fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc7:	c9                   	leave
80100fc8:	c3                   	ret

80100fc9 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc9:	55                   	push   %ebp
80100fca:	89 e5                	mov    %esp,%ebp
80100fcc:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fcf:	83 ec 08             	sub    $0x8,%esp
80100fd2:	68 dc a1 10 80       	push   $0x8010a1dc
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 08 38 00 00       	call   801047e9 <initlock>
80100fe1:	83 c4 10             	add    $0x10,%esp
}
80100fe4:	90                   	nop
80100fe5:	c9                   	leave
80100fe6:	c3                   	ret

80100fe7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fe7:	55                   	push   %ebp
80100fe8:	89 e5                	mov    %esp,%ebp
80100fea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fed:	83 ec 0c             	sub    $0xc,%esp
80100ff0:	68 a0 1a 19 80       	push   $0x80191aa0
80100ff5:	e8 11 38 00 00       	call   8010480b <acquire>
80100ffa:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ffd:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80101004:	eb 2d                	jmp    80101033 <filealloc+0x4c>
    if(f->ref == 0){
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	8b 40 04             	mov    0x4(%eax),%eax
8010100c:	85 c0                	test   %eax,%eax
8010100e:	75 1f                	jne    8010102f <filealloc+0x48>
      f->ref = 1;
80101010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101013:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 a0 1a 19 80       	push   $0x80191aa0
80101022:	e8 52 38 00 00       	call   80104879 <release>
80101027:	83 c4 10             	add    $0x10,%esp
      return f;
8010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102d:	eb 23                	jmp    80101052 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101033:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101038:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103b:	72 c9                	jb     80101006 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 1a 19 80       	push   $0x80191aa0
80101045:	e8 2f 38 00 00       	call   80104879 <release>
8010104a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010104d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101052:	c9                   	leave
80101053:	c3                   	ret

80101054 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101054:	55                   	push   %ebp
80101055:	89 e5                	mov    %esp,%ebp
80101057:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 a0 1a 19 80       	push   $0x80191aa0
80101062:	e8 a4 37 00 00       	call   8010480b <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 e3 a1 10 80       	push   $0x8010a1e3
8010107c:	e8 40 f5 ff ff       	call   801005c1 <panic>
  f->ref++;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	8d 50 01             	lea    0x1(%eax),%edx
8010108a:	8b 45 08             	mov    0x8(%ebp),%eax
8010108d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 a0 1a 19 80       	push   $0x80191aa0
80101098:	e8 dc 37 00 00       	call   80104879 <release>
8010109d:	83 c4 10             	add    $0x10,%esp
  return f;
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a3:	c9                   	leave
801010a4:	c3                   	ret

801010a5 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a5:	55                   	push   %ebp
801010a6:	89 e5                	mov    %esp,%ebp
801010a8:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ab:	83 ec 0c             	sub    $0xc,%esp
801010ae:	68 a0 1a 19 80       	push   $0x80191aa0
801010b3:	e8 53 37 00 00       	call   8010480b <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 eb a1 10 80       	push   $0x8010a1eb
801010cd:	e8 ef f4 ff ff       	call   801005c1 <panic>
  if(--f->ref > 0){
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 04             	mov    0x4(%eax),%eax
801010d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801010db:	8b 45 08             	mov    0x8(%ebp),%eax
801010de:	89 50 04             	mov    %edx,0x4(%eax)
801010e1:	8b 45 08             	mov    0x8(%ebp),%eax
801010e4:	8b 40 04             	mov    0x4(%eax),%eax
801010e7:	85 c0                	test   %eax,%eax
801010e9:	7e 15                	jle    80101100 <fileclose+0x5b>
    release(&ftable.lock);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 a0 1a 19 80       	push   $0x80191aa0
801010f3:	e8 81 37 00 00       	call   80104879 <release>
801010f8:	83 c4 10             	add    $0x10,%esp
801010fb:	e9 8b 00 00 00       	jmp    8010118b <fileclose+0xe6>
    return;
  }
  ff = *f;
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	8b 10                	mov    (%eax),%edx
80101105:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101108:	8b 50 04             	mov    0x4(%eax),%edx
8010110b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010110e:	8b 50 08             	mov    0x8(%eax),%edx
80101111:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101114:	8b 50 0c             	mov    0xc(%eax),%edx
80101117:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010111a:	8b 50 10             	mov    0x10(%eax),%edx
8010111d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101120:	8b 40 14             	mov    0x14(%eax),%eax
80101123:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101130:	8b 45 08             	mov    0x8(%ebp),%eax
80101133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	68 a0 1a 19 80       	push   $0x80191aa0
80101141:	e8 33 37 00 00       	call   80104879 <release>
80101146:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101149:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114c:	83 f8 01             	cmp    $0x1,%eax
8010114f:	75 19                	jne    8010116a <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101151:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101155:	0f be d0             	movsbl %al,%edx
80101158:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010115b:	83 ec 08             	sub    $0x8,%esp
8010115e:	52                   	push   %edx
8010115f:	50                   	push   %eax
80101160:	e8 5a 25 00 00       	call   801036bf <pipeclose>
80101165:	83 c4 10             	add    $0x10,%esp
80101168:	eb 21                	jmp    8010118b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010116d:	83 f8 02             	cmp    $0x2,%eax
80101170:	75 19                	jne    8010118b <fileclose+0xe6>
    begin_op();
80101172:	e8 c7 1e 00 00       	call   8010303e <begin_op>
    iput(ff.ip);
80101177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	50                   	push   %eax
8010117e:	e8 d0 09 00 00       	call   80101b53 <iput>
80101183:	83 c4 10             	add    $0x10,%esp
    end_op();
80101186:	e8 3f 1f 00 00       	call   801030ca <end_op>
  }
}
8010118b:	c9                   	leave
8010118c:	c3                   	ret

8010118d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010118d:	55                   	push   %ebp
8010118e:	89 e5                	mov    %esp,%ebp
80101190:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 00                	mov    (%eax),%eax
80101198:	83 f8 02             	cmp    $0x2,%eax
8010119b:	75 40                	jne    801011dd <filestat+0x50>
    ilock(f->ip);
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	8b 40 10             	mov    0x10(%eax),%eax
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	50                   	push   %eax
801011a7:	e8 46 08 00 00       	call   801019f2 <ilock>
801011ac:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 40 10             	mov    0x10(%eax),%eax
801011b5:	83 ec 08             	sub    $0x8,%esp
801011b8:	ff 75 0c             	push   0xc(%ebp)
801011bb:	50                   	push   %eax
801011bc:	e8 d7 0c 00 00       	call   80101e98 <stati>
801011c1:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011c4:	8b 45 08             	mov    0x8(%ebp),%eax
801011c7:	8b 40 10             	mov    0x10(%eax),%eax
801011ca:	83 ec 0c             	sub    $0xc,%esp
801011cd:	50                   	push   %eax
801011ce:	e8 32 09 00 00       	call   80101b05 <iunlock>
801011d3:	83 c4 10             	add    $0x10,%esp
    return 0;
801011d6:	b8 00 00 00 00       	mov    $0x0,%eax
801011db:	eb 05                	jmp    801011e2 <filestat+0x55>
  }
  return -1;
801011dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011e2:	c9                   	leave
801011e3:	c3                   	ret

801011e4 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011e4:	55                   	push   %ebp
801011e5:	89 e5                	mov    %esp,%ebp
801011e7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ea:	8b 45 08             	mov    0x8(%ebp),%eax
801011ed:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011f1:	84 c0                	test   %al,%al
801011f3:	75 0a                	jne    801011ff <fileread+0x1b>
    return -1;
801011f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011fa:	e9 9b 00 00 00       	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 00                	mov    (%eax),%eax
80101204:	83 f8 01             	cmp    $0x1,%eax
80101207:	75 1a                	jne    80101223 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 40 0c             	mov    0xc(%eax),%eax
8010120f:	83 ec 04             	sub    $0x4,%esp
80101212:	ff 75 10             	push   0x10(%ebp)
80101215:	ff 75 0c             	push   0xc(%ebp)
80101218:	50                   	push   %eax
80101219:	e8 4e 26 00 00       	call   8010386c <piperead>
8010121e:	83 c4 10             	add    $0x10,%esp
80101221:	eb 77                	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_INODE){
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 00                	mov    (%eax),%eax
80101228:	83 f8 02             	cmp    $0x2,%eax
8010122b:	75 60                	jne    8010128d <fileread+0xa9>
    ilock(f->ip);
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 0c             	sub    $0xc,%esp
80101236:	50                   	push   %eax
80101237:	e8 b6 07 00 00       	call   801019f2 <ilock>
8010123c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010123f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 40 10             	mov    0x10(%eax),%eax
8010124e:	51                   	push   %ecx
8010124f:	52                   	push   %edx
80101250:	ff 75 0c             	push   0xc(%ebp)
80101253:	50                   	push   %eax
80101254:	e8 85 0c 00 00       	call   80101ede <readi>
80101259:	83 c4 10             	add    $0x10,%esp
8010125c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010125f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101263:	7e 11                	jle    80101276 <fileread+0x92>
      f->off += r;
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 50 14             	mov    0x14(%eax),%edx
8010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126e:	01 c2                	add    %eax,%edx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 40 10             	mov    0x10(%eax),%eax
8010127c:	83 ec 0c             	sub    $0xc,%esp
8010127f:	50                   	push   %eax
80101280:	e8 80 08 00 00       	call   80101b05 <iunlock>
80101285:	83 c4 10             	add    $0x10,%esp
    return r;
80101288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128b:	eb 0d                	jmp    8010129a <fileread+0xb6>
  }
  panic("fileread");
8010128d:	83 ec 0c             	sub    $0xc,%esp
80101290:	68 f5 a1 10 80       	push   $0x8010a1f5
80101295:	e8 27 f3 ff ff       	call   801005c1 <panic>
}
8010129a:	c9                   	leave
8010129b:	c3                   	ret

8010129c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010129c:	55                   	push   %ebp
8010129d:	89 e5                	mov    %esp,%ebp
8010129f:	53                   	push   %ebx
801012a0:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012aa:	84 c0                	test   %al,%al
801012ac:	75 0a                	jne    801012b8 <filewrite+0x1c>
    return -1;
801012ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b3:	e9 1b 01 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 00                	mov    (%eax),%eax
801012bd:	83 f8 01             	cmp    $0x1,%eax
801012c0:	75 1d                	jne    801012df <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 40 0c             	mov    0xc(%eax),%eax
801012c8:	83 ec 04             	sub    $0x4,%esp
801012cb:	ff 75 10             	push   0x10(%ebp)
801012ce:	ff 75 0c             	push   0xc(%ebp)
801012d1:	50                   	push   %eax
801012d2:	e8 93 24 00 00       	call   8010376a <pipewrite>
801012d7:	83 c4 10             	add    $0x10,%esp
801012da:	e9 f4 00 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_INODE){
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 00                	mov    (%eax),%eax
801012e4:	83 f8 02             	cmp    $0x2,%eax
801012e7:	0f 85 d9 00 00 00    	jne    801013c6 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012ed:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012fb:	e9 a3 00 00 00       	jmp    801013a3 <filewrite+0x107>
      int n1 = n - i;
80101300:	8b 45 10             	mov    0x10(%ebp),%eax
80101303:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101306:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010130c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010130f:	7e 06                	jle    80101317 <filewrite+0x7b>
        n1 = max;
80101311:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101314:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101317:	e8 22 1d 00 00       	call   8010303e <begin_op>
      ilock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 c7 06 00 00       	call   801019f2 <ilock>
8010132b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010132e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	01 c3                	add    %eax,%ebx
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	8b 40 10             	mov    0x10(%eax),%eax
80101345:	51                   	push   %ecx
80101346:	52                   	push   %edx
80101347:	53                   	push   %ebx
80101348:	50                   	push   %eax
80101349:	e8 e5 0c 00 00       	call   80102033 <writei>
8010134e:	83 c4 10             	add    $0x10,%esp
80101351:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101354:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101358:	7e 11                	jle    8010136b <filewrite+0xcf>
        f->off += r;
8010135a:	8b 45 08             	mov    0x8(%ebp),%eax
8010135d:	8b 50 14             	mov    0x14(%eax),%edx
80101360:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101363:	01 c2                	add    %eax,%edx
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	8b 40 10             	mov    0x10(%eax),%eax
80101371:	83 ec 0c             	sub    $0xc,%esp
80101374:	50                   	push   %eax
80101375:	e8 8b 07 00 00       	call   80101b05 <iunlock>
8010137a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010137d:	e8 48 1d 00 00       	call   801030ca <end_op>

      if(r < 0)
80101382:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101386:	78 29                	js     801013b1 <filewrite+0x115>
        break;
      if(r != n1)
80101388:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010138e:	74 0d                	je     8010139d <filewrite+0x101>
        panic("short filewrite");
80101390:	83 ec 0c             	sub    $0xc,%esp
80101393:	68 fe a1 10 80       	push   $0x8010a1fe
80101398:	e8 24 f2 ff ff       	call   801005c1 <panic>
      i += r;
8010139d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a0:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a9:	0f 8c 51 ff ff ff    	jl     80101300 <filewrite+0x64>
801013af:	eb 01                	jmp    801013b2 <filewrite+0x116>
        break;
801013b1:	90                   	nop
    }
    return i == n ? n : -1;
801013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013b8:	75 05                	jne    801013bf <filewrite+0x123>
801013ba:	8b 45 10             	mov    0x10(%ebp),%eax
801013bd:	eb 14                	jmp    801013d3 <filewrite+0x137>
801013bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c4:	eb 0d                	jmp    801013d3 <filewrite+0x137>
  }
  panic("filewrite");
801013c6:	83 ec 0c             	sub    $0xc,%esp
801013c9:	68 0e a2 10 80       	push   $0x8010a20e
801013ce:	e8 ee f1 ff ff       	call   801005c1 <panic>
}
801013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013d6:	c9                   	leave
801013d7:	c3                   	ret

801013d8 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013d8:	55                   	push   %ebp
801013d9:	89 e5                	mov    %esp,%ebp
801013db:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	83 ec 08             	sub    $0x8,%esp
801013e4:	6a 01                	push   $0x1
801013e6:	50                   	push   %eax
801013e7:	e8 15 ee ff ff       	call   80100201 <bread>
801013ec:	83 c4 10             	add    $0x10,%esp
801013ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f5:	83 c0 5c             	add    $0x5c,%eax
801013f8:	83 ec 04             	sub    $0x4,%esp
801013fb:	6a 1c                	push   $0x1c
801013fd:	50                   	push   %eax
801013fe:	ff 75 0c             	push   0xc(%ebp)
80101401:	e8 3a 37 00 00       	call   80104b40 <memmove>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	push   -0xc(%ebp)
8010140f:	e8 6f ee ff ff       	call   80100283 <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave
80101419:	c3                   	ret

8010141a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101420:	8b 55 0c             	mov    0xc(%ebp),%edx
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	83 ec 08             	sub    $0x8,%esp
80101429:	52                   	push   %edx
8010142a:	50                   	push   %eax
8010142b:	e8 d1 ed ff ff       	call   80100201 <bread>
80101430:	83 c4 10             	add    $0x10,%esp
80101433:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101439:	83 c0 5c             	add    $0x5c,%eax
8010143c:	83 ec 04             	sub    $0x4,%esp
8010143f:	68 00 02 00 00       	push   $0x200
80101444:	6a 00                	push   $0x0
80101446:	50                   	push   %eax
80101447:	e8 35 36 00 00       	call   80104a81 <memset>
8010144c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010144f:	83 ec 0c             	sub    $0xc,%esp
80101452:	ff 75 f4             	push   -0xc(%ebp)
80101455:	e8 1d 1e 00 00       	call   80103277 <log_write>
8010145a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010145d:	83 ec 0c             	sub    $0xc,%esp
80101460:	ff 75 f4             	push   -0xc(%ebp)
80101463:	e8 1b ee ff ff       	call   80100283 <brelse>
80101468:	83 c4 10             	add    $0x10,%esp
}
8010146b:	90                   	nop
8010146c:	c9                   	leave
8010146d:	c3                   	ret

8010146e <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010146e:	55                   	push   %ebp
8010146f:	89 e5                	mov    %esp,%ebp
80101471:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101474:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010147b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101482:	e9 0b 01 00 00       	jmp    80101592 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101490:	85 c0                	test   %eax,%eax
80101492:	0f 48 c2             	cmovs  %edx,%eax
80101495:	c1 f8 0c             	sar    $0xc,%eax
80101498:	89 c2                	mov    %eax,%edx
8010149a:	a1 58 24 19 80       	mov    0x80192458,%eax
8010149f:	01 d0                	add    %edx,%eax
801014a1:	83 ec 08             	sub    $0x8,%esp
801014a4:	50                   	push   %eax
801014a5:	ff 75 08             	push   0x8(%ebp)
801014a8:	e8 54 ed ff ff       	call   80100201 <bread>
801014ad:	83 c4 10             	add    $0x10,%esp
801014b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014ba:	e9 9e 00 00 00       	jmp    8010155d <balloc+0xef>
      m = 1 << (bi % 8);
801014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c2:	83 e0 07             	and    $0x7,%eax
801014c5:	ba 01 00 00 00       	mov    $0x1,%edx
801014ca:	89 c1                	mov    %eax,%ecx
801014cc:	d3 e2                	shl    %cl,%edx
801014ce:	89 d0                	mov    %edx,%eax
801014d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	8d 50 07             	lea    0x7(%eax),%edx
801014d9:	85 c0                	test   %eax,%eax
801014db:	0f 48 c2             	cmovs  %edx,%eax
801014de:	c1 f8 03             	sar    $0x3,%eax
801014e1:	89 c2                	mov    %eax,%edx
801014e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014e6:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014eb:	0f b6 c0             	movzbl %al,%eax
801014ee:	23 45 e8             	and    -0x18(%ebp),%eax
801014f1:	85 c0                	test   %eax,%eax
801014f3:	75 64                	jne    80101559 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f8:	8d 50 07             	lea    0x7(%eax),%edx
801014fb:	85 c0                	test   %eax,%eax
801014fd:	0f 48 c2             	cmovs  %edx,%eax
80101500:	c1 f8 03             	sar    $0x3,%eax
80101503:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101506:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010150b:	89 d1                	mov    %edx,%ecx
8010150d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101510:	09 ca                	or     %ecx,%edx
80101512:	89 d1                	mov    %edx,%ecx
80101514:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101517:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010151b:	83 ec 0c             	sub    $0xc,%esp
8010151e:	ff 75 ec             	push   -0x14(%ebp)
80101521:	e8 51 1d 00 00       	call   80103277 <log_write>
80101526:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101529:	83 ec 0c             	sub    $0xc,%esp
8010152c:	ff 75 ec             	push   -0x14(%ebp)
8010152f:	e8 4f ed ff ff       	call   80100283 <brelse>
80101534:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	01 c2                	add    %eax,%edx
8010153f:	8b 45 08             	mov    0x8(%ebp),%eax
80101542:	83 ec 08             	sub    $0x8,%esp
80101545:	52                   	push   %edx
80101546:	50                   	push   %eax
80101547:	e8 ce fe ff ff       	call   8010141a <bzero>
8010154c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	01 d0                	add    %edx,%eax
80101557:	eb 56                	jmp    801015af <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101559:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010155d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101564:	7f 17                	jg     8010157d <balloc+0x10f>
80101566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	01 d0                	add    %edx,%eax
8010156e:	89 c2                	mov    %eax,%edx
80101570:	a1 40 24 19 80       	mov    0x80192440,%eax
80101575:	39 c2                	cmp    %eax,%edx
80101577:	0f 82 42 ff ff ff    	jb     801014bf <balloc+0x51>
      }
    }
    brelse(bp);
8010157d:	83 ec 0c             	sub    $0xc,%esp
80101580:	ff 75 ec             	push   -0x14(%ebp)
80101583:	e8 fb ec ff ff       	call   80100283 <brelse>
80101588:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010158b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101592:	a1 40 24 19 80       	mov    0x80192440,%eax
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	39 c2                	cmp    %eax,%edx
8010159c:	0f 82 e5 fe ff ff    	jb     80101487 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a2:	83 ec 0c             	sub    $0xc,%esp
801015a5:	68 18 a2 10 80       	push   $0x8010a218
801015aa:	e8 12 f0 ff ff       	call   801005c1 <panic>
}
801015af:	c9                   	leave
801015b0:	c3                   	ret

801015b1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015b1:	55                   	push   %ebp
801015b2:	89 e5                	mov    %esp,%ebp
801015b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015b7:	83 ec 08             	sub    $0x8,%esp
801015ba:	68 40 24 19 80       	push   $0x80192440
801015bf:	ff 75 08             	push   0x8(%ebp)
801015c2:	e8 11 fe ff ff       	call   801013d8 <readsb>
801015c7:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cd:	c1 e8 0c             	shr    $0xc,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	a1 58 24 19 80       	mov    0x80192458,%eax
801015d7:	01 c2                	add    %eax,%edx
801015d9:	8b 45 08             	mov    0x8(%ebp),%eax
801015dc:	83 ec 08             	sub    $0x8,%esp
801015df:	52                   	push   %edx
801015e0:	50                   	push   %eax
801015e1:	e8 1b ec ff ff       	call   80100201 <bread>
801015e6:	83 c4 10             	add    $0x10,%esp
801015e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ef:	25 ff 0f 00 00       	and    $0xfff,%eax
801015f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	83 e0 07             	and    $0x7,%eax
801015fd:	ba 01 00 00 00       	mov    $0x1,%edx
80101602:	89 c1                	mov    %eax,%ecx
80101604:	d3 e2                	shl    %cl,%edx
80101606:	89 d0                	mov    %edx,%eax
80101608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160e:	8d 50 07             	lea    0x7(%eax),%edx
80101611:	85 c0                	test   %eax,%eax
80101613:	0f 48 c2             	cmovs  %edx,%eax
80101616:	c1 f8 03             	sar    $0x3,%eax
80101619:	89 c2                	mov    %eax,%edx
8010161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101623:	0f b6 c0             	movzbl %al,%eax
80101626:	23 45 ec             	and    -0x14(%ebp),%eax
80101629:	85 c0                	test   %eax,%eax
8010162b:	75 0d                	jne    8010163a <bfree+0x89>
    panic("freeing free block");
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	68 2e a2 10 80       	push   $0x8010a22e
80101635:	e8 87 ef ff ff       	call   801005c1 <panic>
  bp->data[bi/8] &= ~m;
8010163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163d:	8d 50 07             	lea    0x7(%eax),%edx
80101640:	85 c0                	test   %eax,%eax
80101642:	0f 48 c2             	cmovs  %edx,%eax
80101645:	c1 f8 03             	sar    $0x3,%eax
80101648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164b:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101655:	f7 d2                	not    %edx
80101657:	21 ca                	and    %ecx,%edx
80101659:	89 d1                	mov    %edx,%ecx
8010165b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101662:	83 ec 0c             	sub    $0xc,%esp
80101665:	ff 75 f4             	push   -0xc(%ebp)
80101668:	e8 0a 1c 00 00       	call   80103277 <log_write>
8010166d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101670:	83 ec 0c             	sub    $0xc,%esp
80101673:	ff 75 f4             	push   -0xc(%ebp)
80101676:	e8 08 ec ff ff       	call   80100283 <brelse>
8010167b:	83 c4 10             	add    $0x10,%esp
}
8010167e:	90                   	nop
8010167f:	c9                   	leave
80101680:	c3                   	ret

80101681 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101681:	55                   	push   %ebp
80101682:	89 e5                	mov    %esp,%ebp
80101684:	57                   	push   %edi
80101685:	56                   	push   %esi
80101686:	53                   	push   %ebx
80101687:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010168a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101691:	83 ec 08             	sub    $0x8,%esp
80101694:	68 41 a2 10 80       	push   $0x8010a241
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 46 31 00 00       	call   801047e9 <initlock>
801016a3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016ad:	eb 2d                	jmp    801016dc <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016b2:	89 d0                	mov    %edx,%eax
801016b4:	c1 e0 03             	shl    $0x3,%eax
801016b7:	01 d0                	add    %edx,%eax
801016b9:	c1 e0 04             	shl    $0x4,%eax
801016bc:	83 c0 30             	add    $0x30,%eax
801016bf:	05 60 24 19 80       	add    $0x80192460,%eax
801016c4:	83 c0 10             	add    $0x10,%eax
801016c7:	83 ec 08             	sub    $0x8,%esp
801016ca:	68 48 a2 10 80       	push   $0x8010a248
801016cf:	50                   	push   %eax
801016d0:	e8 b7 2f 00 00       	call   8010468c <initsleeplock>
801016d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016dc:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e0:	7e cd                	jle    801016af <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	68 40 24 19 80       	push   $0x80192440
801016ea:	ff 75 08             	push   0x8(%ebp)
801016ed:	e8 e6 fc ff ff       	call   801013d8 <readsb>
801016f2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016f5:	a1 58 24 19 80       	mov    0x80192458,%eax
801016fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016fd:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
80101703:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101709:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
8010170f:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
80101715:	8b 15 44 24 19 80    	mov    0x80192444,%edx
8010171b:	a1 40 24 19 80       	mov    0x80192440,%eax
80101720:	ff 75 d4             	push   -0x2c(%ebp)
80101723:	57                   	push   %edi
80101724:	56                   	push   %esi
80101725:	53                   	push   %ebx
80101726:	51                   	push   %ecx
80101727:	52                   	push   %edx
80101728:	50                   	push   %eax
80101729:	68 50 a2 10 80       	push   $0x8010a250
8010172e:	e8 c1 ec ff ff       	call   801003f4 <cprintf>
80101733:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101736:	90                   	nop
80101737:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010173a:	5b                   	pop    %ebx
8010173b:	5e                   	pop    %esi
8010173c:	5f                   	pop    %edi
8010173d:	5d                   	pop    %ebp
8010173e:	c3                   	ret

8010173f <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010173f:	55                   	push   %ebp
80101740:	89 e5                	mov    %esp,%ebp
80101742:	83 ec 28             	sub    $0x28,%esp
80101745:	8b 45 0c             	mov    0xc(%ebp),%eax
80101748:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010174c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101753:	e9 9e 00 00 00       	jmp    801017f6 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175b:	c1 e8 03             	shr    $0x3,%eax
8010175e:	89 c2                	mov    %eax,%edx
80101760:	a1 54 24 19 80       	mov    0x80192454,%eax
80101765:	01 d0                	add    %edx,%eax
80101767:	83 ec 08             	sub    $0x8,%esp
8010176a:	50                   	push   %eax
8010176b:	ff 75 08             	push   0x8(%ebp)
8010176e:	e8 8e ea ff ff       	call   80100201 <bread>
80101773:	83 c4 10             	add    $0x10,%esp
80101776:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101782:	83 e0 07             	and    $0x7,%eax
80101785:	c1 e0 06             	shl    $0x6,%eax
80101788:	01 d0                	add    %edx,%eax
8010178a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010178d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101790:	0f b7 00             	movzwl (%eax),%eax
80101793:	66 85 c0             	test   %ax,%ax
80101796:	75 4c                	jne    801017e4 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101798:	83 ec 04             	sub    $0x4,%esp
8010179b:	6a 40                	push   $0x40
8010179d:	6a 00                	push   $0x0
8010179f:	ff 75 ec             	push   -0x14(%ebp)
801017a2:	e8 da 32 00 00       	call   80104a81 <memset>
801017a7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ad:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f0             	push   -0x10(%ebp)
801017ba:	e8 b8 1a 00 00       	call   80103277 <log_write>
801017bf:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017c2:	83 ec 0c             	sub    $0xc,%esp
801017c5:	ff 75 f0             	push   -0x10(%ebp)
801017c8:	e8 b6 ea ff ff       	call   80100283 <brelse>
801017cd:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	50                   	push   %eax
801017d7:	ff 75 08             	push   0x8(%ebp)
801017da:	e8 f7 00 00 00       	call   801018d6 <iget>
801017df:	83 c4 10             	add    $0x10,%esp
801017e2:	eb 2f                	jmp    80101813 <ialloc+0xd4>
    }
    brelse(bp);
801017e4:	83 ec 0c             	sub    $0xc,%esp
801017e7:	ff 75 f0             	push   -0x10(%ebp)
801017ea:	e8 94 ea ff ff       	call   80100283 <brelse>
801017ef:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017f6:	a1 48 24 19 80       	mov    0x80192448,%eax
801017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 52 ff ff ff    	jb     80101758 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 a3 a2 10 80       	push   $0x8010a2a3
8010180e:	e8 ae ed ff ff       	call   801005c1 <panic>
}
80101813:	c9                   	leave
80101814:	c3                   	ret

80101815 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101815:	55                   	push   %ebp
80101816:	89 e5                	mov    %esp,%ebp
80101818:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8b 40 04             	mov    0x4(%eax),%eax
80101821:	c1 e8 03             	shr    $0x3,%eax
80101824:	89 c2                	mov    %eax,%edx
80101826:	a1 54 24 19 80       	mov    0x80192454,%eax
8010182b:	01 c2                	add    %eax,%edx
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 00                	mov    (%eax),%eax
80101832:	83 ec 08             	sub    $0x8,%esp
80101835:	52                   	push   %edx
80101836:	50                   	push   %eax
80101837:	e8 c5 e9 ff ff       	call   80100201 <bread>
8010183c:	83 c4 10             	add    $0x10,%esp
8010183f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	8d 50 5c             	lea    0x5c(%eax),%edx
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 04             	mov    0x4(%eax),%eax
8010184e:	83 e0 07             	and    $0x7,%eax
80101851:	c1 e0 06             	shl    $0x6,%eax
80101854:	01 d0                	add    %edx,%eax
80101856:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101863:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101866:	8b 45 08             	mov    0x8(%ebp),%eax
80101869:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101870:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101882:	8b 45 08             	mov    0x8(%ebp),%eax
80101885:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 50 58             	mov    0x58(%eax),%edx
80101896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101899:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a5:	83 c0 0c             	add    $0xc,%eax
801018a8:	83 ec 04             	sub    $0x4,%esp
801018ab:	6a 34                	push   $0x34
801018ad:	52                   	push   %edx
801018ae:	50                   	push   %eax
801018af:	e8 8c 32 00 00       	call   80104b40 <memmove>
801018b4:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	ff 75 f4             	push   -0xc(%ebp)
801018bd:	e8 b5 19 00 00       	call   80103277 <log_write>
801018c2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018c5:	83 ec 0c             	sub    $0xc,%esp
801018c8:	ff 75 f4             	push   -0xc(%ebp)
801018cb:	e8 b3 e9 ff ff       	call   80100283 <brelse>
801018d0:	83 c4 10             	add    $0x10,%esp
}
801018d3:	90                   	nop
801018d4:	c9                   	leave
801018d5:	c3                   	ret

801018d6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018d6:	55                   	push   %ebp
801018d7:	89 e5                	mov    %esp,%ebp
801018d9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018dc:	83 ec 0c             	sub    $0xc,%esp
801018df:	68 60 24 19 80       	push   $0x80192460
801018e4:	e8 22 2f 00 00       	call   8010480b <acquire>
801018e9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f3:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018fa:	eb 60                	jmp    8010195c <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ff:	8b 40 08             	mov    0x8(%eax),%eax
80101902:	85 c0                	test   %eax,%eax
80101904:	7e 39                	jle    8010193f <iget+0x69>
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8b 00                	mov    (%eax),%eax
8010190b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010190e:	75 2f                	jne    8010193f <iget+0x69>
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101913:	8b 40 04             	mov    0x4(%eax),%eax
80101916:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101919:	75 24                	jne    8010193f <iget+0x69>
      ip->ref++;
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 40 08             	mov    0x8(%eax),%eax
80101921:	8d 50 01             	lea    0x1(%eax),%edx
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010192a:	83 ec 0c             	sub    $0xc,%esp
8010192d:	68 60 24 19 80       	push   $0x80192460
80101932:	e8 42 2f 00 00       	call   80104879 <release>
80101937:	83 c4 10             	add    $0x10,%esp
      return ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193d:	eb 77                	jmp    801019b6 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010193f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101943:	75 10                	jne    80101955 <iget+0x7f>
80101945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101948:	8b 40 08             	mov    0x8(%eax),%eax
8010194b:	85 c0                	test   %eax,%eax
8010194d:	75 06                	jne    80101955 <iget+0x7f>
      empty = ip;
8010194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101955:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010195c:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101963:	72 97                	jb     801018fc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101965:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101969:	75 0d                	jne    80101978 <iget+0xa2>
    panic("iget: no inodes");
8010196b:	83 ec 0c             	sub    $0xc,%esp
8010196e:	68 b5 a2 10 80       	push   $0x8010a2b5
80101973:	e8 49 ec ff ff       	call   801005c1 <panic>

  ip = empty;
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 08             	mov    0x8(%ebp),%edx
80101984:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010198c:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019a3:	83 ec 0c             	sub    $0xc,%esp
801019a6:	68 60 24 19 80       	push   $0x80192460
801019ab:	e8 c9 2e 00 00       	call   80104879 <release>
801019b0:	83 c4 10             	add    $0x10,%esp

  return ip;
801019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019b6:	c9                   	leave
801019b7:	c3                   	ret

801019b8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b8:	55                   	push   %ebp
801019b9:	89 e5                	mov    %esp,%ebp
801019bb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019be:	83 ec 0c             	sub    $0xc,%esp
801019c1:	68 60 24 19 80       	push   $0x80192460
801019c6:	e8 40 2e 00 00       	call   8010480b <acquire>
801019cb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 08             	mov    0x8(%eax),%eax
801019d4:	8d 50 01             	lea    0x1(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 60 24 19 80       	push   $0x80192460
801019e5:	e8 8f 2e 00 00       	call   80104879 <release>
801019ea:	83 c4 10             	add    $0x10,%esp
  return ip;
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019f0:	c9                   	leave
801019f1:	c3                   	ret

801019f2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019f2:	55                   	push   %ebp
801019f3:	89 e5                	mov    %esp,%ebp
801019f5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019fc:	74 0a                	je     80101a08 <ilock+0x16>
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	8b 40 08             	mov    0x8(%eax),%eax
80101a04:	85 c0                	test   %eax,%eax
80101a06:	7f 0d                	jg     80101a15 <ilock+0x23>
    panic("ilock");
80101a08:	83 ec 0c             	sub    $0xc,%esp
80101a0b:	68 c5 a2 10 80       	push   $0x8010a2c5
80101a10:	e8 ac eb ff ff       	call   801005c1 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 a4 2c 00 00       	call   801046c8 <acquiresleep>
80101a24:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a2d:	85 c0                	test   %eax,%eax
80101a2f:	0f 85 cd 00 00 00    	jne    80101b02 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	8b 40 04             	mov    0x4(%eax),%eax
80101a3b:	c1 e8 03             	shr    $0x3,%eax
80101a3e:	89 c2                	mov    %eax,%edx
80101a40:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a45:	01 c2                	add    %eax,%edx
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	8b 00                	mov    (%eax),%eax
80101a4c:	83 ec 08             	sub    $0x8,%esp
80101a4f:	52                   	push   %edx
80101a50:	50                   	push   %eax
80101a51:	e8 ab e7 ff ff       	call   80100201 <bread>
80101a56:	83 c4 10             	add    $0x10,%esp
80101a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	8b 40 04             	mov    0x4(%eax),%eax
80101a68:	83 e0 07             	and    $0x7,%eax
80101a6b:	c1 e0 06             	shl    $0x6,%eax
80101a6e:	01 d0                	add    %edx,%eax
80101a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	0f b7 10             	movzwl (%eax),%edx
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a83:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a91:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aad:	8b 50 08             	mov    0x8(%eax),%edx
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab9:	8d 50 0c             	lea    0xc(%eax),%edx
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	83 c0 5c             	add    $0x5c,%eax
80101ac2:	83 ec 04             	sub    $0x4,%esp
80101ac5:	6a 34                	push   $0x34
80101ac7:	52                   	push   %edx
80101ac8:	50                   	push   %eax
80101ac9:	e8 72 30 00 00       	call   80104b40 <memmove>
80101ace:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ad1:	83 ec 0c             	sub    $0xc,%esp
80101ad4:	ff 75 f4             	push   -0xc(%ebp)
80101ad7:	e8 a7 e7 ff ff       	call   80100283 <brelse>
80101adc:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101af0:	66 85 c0             	test   %ax,%ax
80101af3:	75 0d                	jne    80101b02 <ilock+0x110>
      panic("ilock: no type");
80101af5:	83 ec 0c             	sub    $0xc,%esp
80101af8:	68 cb a2 10 80       	push   $0x8010a2cb
80101afd:	e8 bf ea ff ff       	call   801005c1 <panic>
  }
}
80101b02:	90                   	nop
80101b03:	c9                   	leave
80101b04:	c3                   	ret

80101b05 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b05:	55                   	push   %ebp
80101b06:	89 e5                	mov    %esp,%ebp
80101b08:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b0f:	74 20                	je     80101b31 <iunlock+0x2c>
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	83 c0 0c             	add    $0xc,%eax
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	50                   	push   %eax
80101b1b:	e8 5a 2c 00 00       	call   8010477a <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 da a2 10 80       	push   $0x8010a2da
80101b39:	e8 83 ea ff ff       	call   801005c1 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 df 2b 00 00       	call   8010472c <releasesleep>
80101b4d:	83 c4 10             	add    $0x10,%esp
}
80101b50:	90                   	nop
80101b51:	c9                   	leave
80101b52:	c3                   	ret

80101b53 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b53:	55                   	push   %ebp
80101b54:	89 e5                	mov    %esp,%ebp
80101b56:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	83 c0 0c             	add    $0xc,%eax
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	50                   	push   %eax
80101b63:	e8 60 2b 00 00       	call   801046c8 <acquiresleep>
80101b68:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 6a                	je     80101bdf <iput+0x8c>
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b7c:	66 85 c0             	test   %ax,%ax
80101b7f:	75 5e                	jne    80101bdf <iput+0x8c>
    acquire(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 60 24 19 80       	push   $0x80192460
80101b89:	e8 7d 2c 00 00       	call   8010480b <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 d2 2c 00 00       	call   80104879 <release>
80101ba7:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101baa:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bae:	75 2f                	jne    80101bdf <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	ff 75 08             	push   0x8(%ebp)
80101bb6:	e8 ad 01 00 00       	call   80101d68 <itrunc>
80101bbb:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc7:	83 ec 0c             	sub    $0xc,%esp
80101bca:	ff 75 08             	push   0x8(%ebp)
80101bcd:	e8 43 fc ff ff       	call   80101815 <iupdate>
80101bd2:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101be2:	83 c0 0c             	add    $0xc,%eax
80101be5:	83 ec 0c             	sub    $0xc,%esp
80101be8:	50                   	push   %eax
80101be9:	e8 3e 2b 00 00       	call   8010472c <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 0d 2c 00 00       	call   8010480b <acquire>
80101bfe:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 08             	mov    0x8(%eax),%eax
80101c07:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 60 24 19 80       	push   $0x80192460
80101c18:	e8 5c 2c 00 00       	call   80104879 <release>
80101c1d:	83 c4 10             	add    $0x10,%esp
}
80101c20:	90                   	nop
80101c21:	c9                   	leave
80101c22:	c3                   	ret

80101c23 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c23:	55                   	push   %ebp
80101c24:	89 e5                	mov    %esp,%ebp
80101c26:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c29:	83 ec 0c             	sub    $0xc,%esp
80101c2c:	ff 75 08             	push   0x8(%ebp)
80101c2f:	e8 d1 fe ff ff       	call   80101b05 <iunlock>
80101c34:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	ff 75 08             	push   0x8(%ebp)
80101c3d:	e8 11 ff ff ff       	call   80101b53 <iput>
80101c42:	83 c4 10             	add    $0x10,%esp
}
80101c45:	90                   	nop
80101c46:	c9                   	leave
80101c47:	c3                   	ret

80101c48 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c48:	55                   	push   %ebp
80101c49:	89 e5                	mov    %esp,%ebp
80101c4b:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c4e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c52:	77 42                	ja     80101c96 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c5a:	83 c2 14             	add    $0x14,%edx
80101c5d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c68:	75 24                	jne    80101c8e <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	8b 00                	mov    (%eax),%eax
80101c6f:	83 ec 0c             	sub    $0xc,%esp
80101c72:	50                   	push   %eax
80101c73:	e8 f6 f7 ff ff       	call   8010146e <balloc>
80101c78:	83 c4 10             	add    $0x10,%esp
80101c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c84:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c8a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c91:	e9 d0 00 00 00       	jmp    80101d66 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c96:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c9a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c9e:	0f 87 b5 00 00 00    	ja     80101d59 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb4:	75 20                	jne    80101cd6 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	50                   	push   %eax
80101cbf:	e8 aa f7 ff ff       	call   8010146e <balloc>
80101cc4:	83 c4 10             	add    $0x10,%esp
80101cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd0:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	8b 00                	mov    (%eax),%eax
80101cdb:	83 ec 08             	sub    $0x8,%esp
80101cde:	ff 75 f4             	push   -0xc(%ebp)
80101ce1:	50                   	push   %eax
80101ce2:	e8 1a e5 ff ff       	call   80100201 <bread>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf0:	83 c0 5c             	add    $0x5c,%eax
80101cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d03:	01 d0                	add    %edx,%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d0e:	75 36                	jne    80101d46 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d10:	8b 45 08             	mov    0x8(%ebp),%eax
80101d13:	8b 00                	mov    (%eax),%eax
80101d15:	83 ec 0c             	sub    $0xc,%esp
80101d18:	50                   	push   %eax
80101d19:	e8 50 f7 ff ff       	call   8010146e <balloc>
80101d1e:	83 c4 10             	add    $0x10,%esp
80101d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d31:	01 c2                	add    %eax,%edx
80101d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d36:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d38:	83 ec 0c             	sub    $0xc,%esp
80101d3b:	ff 75 f0             	push   -0x10(%ebp)
80101d3e:	e8 34 15 00 00       	call   80103277 <log_write>
80101d43:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	ff 75 f0             	push   -0x10(%ebp)
80101d4c:	e8 32 e5 ff ff       	call   80100283 <brelse>
80101d51:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d57:	eb 0d                	jmp    80101d66 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	68 e2 a2 10 80       	push   $0x8010a2e2
80101d61:	e8 5b e8 ff ff       	call   801005c1 <panic>
}
80101d66:	c9                   	leave
80101d67:	c3                   	ret

80101d68 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d75:	eb 45                	jmp    80101dbc <itrunc+0x54>
    if(ip->addrs[i]){
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7d:	83 c2 14             	add    $0x14,%edx
80101d80:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d84:	85 c0                	test   %eax,%eax
80101d86:	74 30                	je     80101db8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8e:	83 c2 14             	add    $0x14,%edx
80101d91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d95:	8b 55 08             	mov    0x8(%ebp),%edx
80101d98:	8b 12                	mov    (%edx),%edx
80101d9a:	83 ec 08             	sub    $0x8,%esp
80101d9d:	50                   	push   %eax
80101d9e:	52                   	push   %edx
80101d9f:	e8 0d f8 ff ff       	call   801015b1 <bfree>
80101da4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da7:	8b 45 08             	mov    0x8(%ebp),%eax
80101daa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dad:	83 c2 14             	add    $0x14,%edx
80101db0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db7:	00 
  for(i = 0; i < NDIRECT; i++){
80101db8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dbc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc0:	7e b5                	jle    80101d77 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dcb:	85 c0                	test   %eax,%eax
80101dcd:	0f 84 aa 00 00 00    	je     80101e7d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 16 e4 ff ff       	call   80100201 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 5c             	add    $0x5c,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd7>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 79 f7 ff ff       	call   801015b1 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x9b>
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	push   -0x14(%ebp)
80101e4d:	e8 31 e4 ff ff       	call   80100283 <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e61:	8b 12                	mov    (%edx),%edx
80101e63:	83 ec 08             	sub    $0x8,%esp
80101e66:	50                   	push   %eax
80101e67:	52                   	push   %edx
80101e68:	e8 44 f7 ff ff       	call   801015b1 <bfree>
80101e6d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e7a:	00 00 00 
  }

  ip->size = 0;
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e87:	83 ec 0c             	sub    $0xc,%esp
80101e8a:	ff 75 08             	push   0x8(%ebp)
80101e8d:	e8 83 f9 ff ff       	call   80101815 <iupdate>
80101e92:	83 c4 10             	add    $0x10,%esp
}
80101e95:	90                   	nop
80101e96:	c9                   	leave
80101e97:	c3                   	ret

80101e98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e98:	55                   	push   %ebp
80101e99:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 00                	mov    (%eax),%eax
80101ea0:	89 c2                	mov    %eax,%edx
80101ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	8b 50 04             	mov    0x4(%eax),%edx
80101eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 50 58             	mov    0x58(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edb:	90                   	nop
80101edc:	5d                   	pop    %ebp
80101edd:	c3                   	ret

80101ede <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ede:	55                   	push   %ebp
80101edf:	89 e5                	mov    %esp,%ebp
80101ee1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101eeb:	66 83 f8 03          	cmp    $0x3,%ax
80101eef:	75 5c                	jne    80101f4d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef8:	66 85 c0             	test   %ax,%ax
80101efb:	78 20                	js     80101f1d <readi+0x3f>
80101efd:	8b 45 08             	mov    0x8(%ebp),%eax
80101f00:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f04:	66 83 f8 09          	cmp    $0x9,%ax
80101f08:	7f 13                	jg     80101f1d <readi+0x3f>
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f11:	98                   	cwtl
80101f12:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0a 01 00 00       	jmp    80102031 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2e:	98                   	cwtl
80101f2f:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f36:	8b 55 14             	mov    0x14(%ebp),%edx
80101f39:	83 ec 04             	sub    $0x4,%esp
80101f3c:	52                   	push   %edx
80101f3d:	ff 75 0c             	push   0xc(%ebp)
80101f40:	ff 75 08             	push   0x8(%ebp)
80101f43:	ff d0                	call   *%eax
80101f45:	83 c4 10             	add    $0x10,%esp
80101f48:	e9 e4 00 00 00       	jmp    80102031 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 40 58             	mov    0x58(%eax),%eax
80101f53:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f56:	72 0d                	jb     80101f65 <readi+0x87>
80101f58:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5e:	01 d0                	add    %edx,%eax
80101f60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f63:	73 0a                	jae    80101f6f <readi+0x91>
    return -1;
80101f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6a:	e9 c2 00 00 00       	jmp    80102031 <readi+0x153>
  if(off + n > ip->size)
80101f6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f72:	8b 45 14             	mov    0x14(%ebp),%eax
80101f75:	01 c2                	add    %eax,%edx
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	8b 40 58             	mov    0x58(%eax),%eax
80101f7d:	39 d0                	cmp    %edx,%eax
80101f7f:	73 0c                	jae    80101f8d <readi+0xaf>
    n = ip->size - off;
80101f81:	8b 45 08             	mov    0x8(%ebp),%eax
80101f84:	8b 40 58             	mov    0x58(%eax),%eax
80101f87:	2b 45 10             	sub    0x10(%ebp),%eax
80101f8a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f94:	e9 89 00 00 00       	jmp    80102022 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f99:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9c:	c1 e8 09             	shr    $0x9,%eax
80101f9f:	83 ec 08             	sub    $0x8,%esp
80101fa2:	50                   	push   %eax
80101fa3:	ff 75 08             	push   0x8(%ebp)
80101fa6:	e8 9d fc ff ff       	call   80101c48 <bmap>
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb1:	8b 12                	mov    (%edx),%edx
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	52                   	push   %edx
80101fb8:	e8 44 e2 ff ff       	call   80100201 <bread>
80101fbd:	83 c4 10             	add    $0x10,%esp
80101fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcb:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd0:	29 c2                	sub    %eax,%edx
80101fd2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd8:	39 c2                	cmp    %eax,%edx
80101fda:	0f 46 c2             	cmovbe %edx,%eax
80101fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fee:	01 d0                	add    %edx,%eax
80101ff0:	83 ec 04             	sub    $0x4,%esp
80101ff3:	ff 75 ec             	push   -0x14(%ebp)
80101ff6:	50                   	push   %eax
80101ff7:	ff 75 0c             	push   0xc(%ebp)
80101ffa:	e8 41 2b 00 00       	call   80104b40 <memmove>
80101fff:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	ff 75 f0             	push   -0x10(%ebp)
80102008:	e8 76 e2 ff ff       	call   80100283 <brelse>
8010200d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102013:	01 45 f4             	add    %eax,-0xc(%ebp)
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 10             	add    %eax,0x10(%ebp)
8010201c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201f:	01 45 0c             	add    %eax,0xc(%ebp)
80102022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102025:	3b 45 14             	cmp    0x14(%ebp),%eax
80102028:	0f 82 6b ff ff ff    	jb     80101f99 <readi+0xbb>
  }
  return n;
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102031:	c9                   	leave
80102032:	c3                   	ret

80102033 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102040:	66 83 f8 03          	cmp    $0x3,%ax
80102044:	75 5c                	jne    801020a2 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204d:	66 85 c0             	test   %ax,%ax
80102050:	78 20                	js     80102072 <writei+0x3f>
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102059:	66 83 f8 09          	cmp    $0x9,%ax
8010205d:	7f 13                	jg     80102072 <writei+0x3f>
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102066:	98                   	cwtl
80102067:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
      return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3b 01 00 00       	jmp    801021b7 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102083:	98                   	cwtl
80102084:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010208b:	8b 55 14             	mov    0x14(%ebp),%edx
8010208e:	83 ec 04             	sub    $0x4,%esp
80102091:	52                   	push   %edx
80102092:	ff 75 0c             	push   0xc(%ebp)
80102095:	ff 75 08             	push   0x8(%ebp)
80102098:	ff d0                	call   *%eax
8010209a:	83 c4 10             	add    $0x10,%esp
8010209d:	e9 15 01 00 00       	jmp    801021b7 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020a2:	8b 45 08             	mov    0x8(%ebp),%eax
801020a5:	8b 40 58             	mov    0x58(%eax),%eax
801020a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020ab:	72 0d                	jb     801020ba <writei+0x87>
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	8b 45 14             	mov    0x14(%ebp),%eax
801020b3:	01 d0                	add    %edx,%eax
801020b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b8:	73 0a                	jae    801020c4 <writei+0x91>
    return -1;
801020ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bf:	e9 f3 00 00 00       	jmp    801021b7 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ca:	01 d0                	add    %edx,%eax
801020cc:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d1:	76 0a                	jbe    801020dd <writei+0xaa>
    return -1;
801020d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d8:	e9 da 00 00 00       	jmp    801021b7 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e4:	e9 97 00 00 00       	jmp    80102180 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ec:	c1 e8 09             	shr    $0x9,%eax
801020ef:	83 ec 08             	sub    $0x8,%esp
801020f2:	50                   	push   %eax
801020f3:	ff 75 08             	push   0x8(%ebp)
801020f6:	e8 4d fb ff ff       	call   80101c48 <bmap>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102101:	8b 12                	mov    (%edx),%edx
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	52                   	push   %edx
80102108:	e8 f4 e0 ff ff       	call   80100201 <bread>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102113:	8b 45 10             	mov    0x10(%ebp),%eax
80102116:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211b:	ba 00 02 00 00       	mov    $0x200,%edx
80102120:	29 c2                	sub    %eax,%edx
80102122:	8b 45 14             	mov    0x14(%ebp),%eax
80102125:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102128:	39 c2                	cmp    %eax,%edx
8010212a:	0f 46 c2             	cmovbe %edx,%eax
8010212d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102133:	8d 50 5c             	lea    0x5c(%eax),%edx
80102136:	8b 45 10             	mov    0x10(%ebp),%eax
80102139:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213e:	01 d0                	add    %edx,%eax
80102140:	83 ec 04             	sub    $0x4,%esp
80102143:	ff 75 ec             	push   -0x14(%ebp)
80102146:	ff 75 0c             	push   0xc(%ebp)
80102149:	50                   	push   %eax
8010214a:	e8 f1 29 00 00       	call   80104b40 <memmove>
8010214f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	ff 75 f0             	push   -0x10(%ebp)
80102158:	e8 1a 11 00 00       	call   80103277 <log_write>
8010215d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102160:	83 ec 0c             	sub    $0xc,%esp
80102163:	ff 75 f0             	push   -0x10(%ebp)
80102166:	e8 18 e1 ff ff       	call   80100283 <brelse>
8010216b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102171:	01 45 f4             	add    %eax,-0xc(%ebp)
80102174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102177:	01 45 10             	add    %eax,0x10(%ebp)
8010217a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217d:	01 45 0c             	add    %eax,0xc(%ebp)
80102180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102183:	3b 45 14             	cmp    0x14(%ebp),%eax
80102186:	0f 82 5d ff ff ff    	jb     801020e9 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010218c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102190:	74 22                	je     801021b4 <writei+0x181>
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	8b 40 58             	mov    0x58(%eax),%eax
80102198:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219b:	73 17                	jae    801021b4 <writei+0x181>
    ip->size = off;
8010219d:	8b 45 08             	mov    0x8(%ebp),%eax
801021a0:	8b 55 10             	mov    0x10(%ebp),%edx
801021a3:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021a6:	83 ec 0c             	sub    $0xc,%esp
801021a9:	ff 75 08             	push   0x8(%ebp)
801021ac:	e8 64 f6 ff ff       	call   80101815 <iupdate>
801021b1:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b7:	c9                   	leave
801021b8:	c3                   	ret

801021b9 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b9:	55                   	push   %ebp
801021ba:	89 e5                	mov    %esp,%ebp
801021bc:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bf:	83 ec 04             	sub    $0x4,%esp
801021c2:	6a 0e                	push   $0xe
801021c4:	ff 75 0c             	push   0xc(%ebp)
801021c7:	ff 75 08             	push   0x8(%ebp)
801021ca:	e8 07 2a 00 00       	call   80104bd6 <strncmp>
801021cf:	83 c4 10             	add    $0x10,%esp
}
801021d2:	c9                   	leave
801021d3:	c3                   	ret

801021d4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d4:	55                   	push   %ebp
801021d5:	89 e5                	mov    %esp,%ebp
801021d7:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021e1:	66 83 f8 01          	cmp    $0x1,%ax
801021e5:	74 0d                	je     801021f4 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e7:	83 ec 0c             	sub    $0xc,%esp
801021ea:	68 f5 a2 10 80       	push   $0x8010a2f5
801021ef:	e8 cd e3 ff ff       	call   801005c1 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021fb:	eb 7b                	jmp    80102278 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fd:	6a 10                	push   $0x10
801021ff:	ff 75 f4             	push   -0xc(%ebp)
80102202:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102205:	50                   	push   %eax
80102206:	ff 75 08             	push   0x8(%ebp)
80102209:	e8 d0 fc ff ff       	call   80101ede <readi>
8010220e:	83 c4 10             	add    $0x10,%esp
80102211:	83 f8 10             	cmp    $0x10,%eax
80102214:	74 0d                	je     80102223 <dirlookup+0x4f>
      panic("dirlookup read");
80102216:	83 ec 0c             	sub    $0xc,%esp
80102219:	68 07 a3 10 80       	push   $0x8010a307
8010221e:	e8 9e e3 ff ff       	call   801005c1 <panic>
    if(de.inum == 0)
80102223:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102227:	66 85 c0             	test   %ax,%ax
8010222a:	74 47                	je     80102273 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222c:	83 ec 08             	sub    $0x8,%esp
8010222f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102232:	83 c0 02             	add    $0x2,%eax
80102235:	50                   	push   %eax
80102236:	ff 75 0c             	push   0xc(%ebp)
80102239:	e8 7b ff ff ff       	call   801021b9 <namecmp>
8010223e:	83 c4 10             	add    $0x10,%esp
80102241:	85 c0                	test   %eax,%eax
80102243:	75 2f                	jne    80102274 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102249:	74 08                	je     80102253 <dirlookup+0x7f>
        *poff = off;
8010224b:	8b 45 10             	mov    0x10(%ebp),%eax
8010224e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102251:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102253:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102257:	0f b7 c0             	movzwl %ax,%eax
8010225a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	8b 00                	mov    (%eax),%eax
80102262:	83 ec 08             	sub    $0x8,%esp
80102265:	ff 75 f0             	push   -0x10(%ebp)
80102268:	50                   	push   %eax
80102269:	e8 68 f6 ff ff       	call   801018d6 <iget>
8010226e:	83 c4 10             	add    $0x10,%esp
80102271:	eb 19                	jmp    8010228c <dirlookup+0xb8>
      continue;
80102273:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102274:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 40 58             	mov    0x58(%eax),%eax
8010227e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102281:	0f 82 76 ff ff ff    	jb     801021fd <dirlookup+0x29>
    }
  }

  return 0;
80102287:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228c:	c9                   	leave
8010228d:	c3                   	ret

8010228e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228e:	55                   	push   %ebp
8010228f:	89 e5                	mov    %esp,%ebp
80102291:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102294:	83 ec 04             	sub    $0x4,%esp
80102297:	6a 00                	push   $0x0
80102299:	ff 75 0c             	push   0xc(%ebp)
8010229c:	ff 75 08             	push   0x8(%ebp)
8010229f:	e8 30 ff ff ff       	call   801021d4 <dirlookup>
801022a4:	83 c4 10             	add    $0x10,%esp
801022a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ae:	74 18                	je     801022c8 <dirlink+0x3a>
    iput(ip);
801022b0:	83 ec 0c             	sub    $0xc,%esp
801022b3:	ff 75 f0             	push   -0x10(%ebp)
801022b6:	e8 98 f8 ff ff       	call   80101b53 <iput>
801022bb:	83 c4 10             	add    $0x10,%esp
    return -1;
801022be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c3:	e9 9c 00 00 00       	jmp    80102364 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cf:	eb 39                	jmp    8010230a <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d4:	6a 10                	push   $0x10
801022d6:	50                   	push   %eax
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	50                   	push   %eax
801022db:	ff 75 08             	push   0x8(%ebp)
801022de:	e8 fb fb ff ff       	call   80101ede <readi>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	83 f8 10             	cmp    $0x10,%eax
801022e9:	74 0d                	je     801022f8 <dirlink+0x6a>
      panic("dirlink read");
801022eb:	83 ec 0c             	sub    $0xc,%esp
801022ee:	68 16 a3 10 80       	push   $0x8010a316
801022f3:	e8 c9 e2 ff ff       	call   801005c1 <panic>
    if(de.inum == 0)
801022f8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fc:	66 85 c0             	test   %ax,%ax
801022ff:	74 18                	je     80102319 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102304:	83 c0 10             	add    $0x10,%eax
80102307:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 58             	mov    0x58(%eax),%eax
80102310:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102313:	39 c2                	cmp    %eax,%edx
80102315:	72 ba                	jb     801022d1 <dirlink+0x43>
80102317:	eb 01                	jmp    8010231a <dirlink+0x8c>
      break;
80102319:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010231a:	83 ec 04             	sub    $0x4,%esp
8010231d:	6a 0e                	push   $0xe
8010231f:	ff 75 0c             	push   0xc(%ebp)
80102322:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102325:	83 c0 02             	add    $0x2,%eax
80102328:	50                   	push   %eax
80102329:	e8 fe 28 00 00       	call   80104c2c <strncpy>
8010232e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	6a 10                	push   $0x10
8010233d:	50                   	push   %eax
8010233e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102341:	50                   	push   %eax
80102342:	ff 75 08             	push   0x8(%ebp)
80102345:	e8 e9 fc ff ff       	call   80102033 <writei>
8010234a:	83 c4 10             	add    $0x10,%esp
8010234d:	83 f8 10             	cmp    $0x10,%eax
80102350:	74 0d                	je     8010235f <dirlink+0xd1>
    panic("dirlink");
80102352:	83 ec 0c             	sub    $0xc,%esp
80102355:	68 23 a3 10 80       	push   $0x8010a323
8010235a:	e8 62 e2 ff ff       	call   801005c1 <panic>

  return 0;
8010235f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102364:	c9                   	leave
80102365:	c3                   	ret

80102366 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102366:	55                   	push   %ebp
80102367:	89 e5                	mov    %esp,%ebp
80102369:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236c:	eb 04                	jmp    80102372 <skipelem+0xc>
    path++;
8010236e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	0f b6 00             	movzbl (%eax),%eax
80102378:	3c 2f                	cmp    $0x2f,%al
8010237a:	74 f2                	je     8010236e <skipelem+0x8>
  if(*path == 0)
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b6 00             	movzbl (%eax),%eax
80102382:	84 c0                	test   %al,%al
80102384:	75 07                	jne    8010238d <skipelem+0x27>
    return 0;
80102386:	b8 00 00 00 00       	mov    $0x0,%eax
8010238b:	eb 77                	jmp    80102404 <skipelem+0x9e>
  s = path;
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102393:	eb 04                	jmp    80102399 <skipelem+0x33>
    path++;
80102395:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b6 00             	movzbl (%eax),%eax
8010239f:	3c 2f                	cmp    $0x2f,%al
801023a1:	74 0a                	je     801023ad <skipelem+0x47>
801023a3:	8b 45 08             	mov    0x8(%ebp),%eax
801023a6:	0f b6 00             	movzbl (%eax),%eax
801023a9:	84 c0                	test   %al,%al
801023ab:	75 e8                	jne    80102395 <skipelem+0x2f>
  len = path - s;
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ba:	7e 15                	jle    801023d1 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023bc:	83 ec 04             	sub    $0x4,%esp
801023bf:	6a 0e                	push   $0xe
801023c1:	ff 75 f4             	push   -0xc(%ebp)
801023c4:	ff 75 0c             	push   0xc(%ebp)
801023c7:	e8 74 27 00 00       	call   80104b40 <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 5d 27 00 00       	call   80104b40 <memmove>
801023e3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ec:	01 d0                	add    %edx,%eax
801023ee:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f1:	eb 04                	jmp    801023f7 <skipelem+0x91>
    path++;
801023f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	3c 2f                	cmp    $0x2f,%al
801023ff:	74 f2                	je     801023f3 <skipelem+0x8d>
  return path;
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102404:	c9                   	leave
80102405:	c3                   	ret

80102406 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	3c 2f                	cmp    $0x2f,%al
80102414:	75 17                	jne    8010242d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102416:	83 ec 08             	sub    $0x8,%esp
80102419:	6a 01                	push   $0x1
8010241b:	6a 01                	push   $0x1
8010241d:	e8 b4 f4 ff ff       	call   801018d6 <iget>
80102422:	83 c4 10             	add    $0x10,%esp
80102425:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102428:	e9 ba 00 00 00       	jmp    801024e7 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010242d:	e8 fe 15 00 00       	call   80103a30 <myproc>
80102432:	8b 40 68             	mov    0x68(%eax),%eax
80102435:	83 ec 0c             	sub    $0xc,%esp
80102438:	50                   	push   %eax
80102439:	e8 7a f5 ff ff       	call   801019b8 <idup>
8010243e:	83 c4 10             	add    $0x10,%esp
80102441:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102444:	e9 9e 00 00 00       	jmp    801024e7 <namex+0xe1>
    ilock(ip);
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	ff 75 f4             	push   -0xc(%ebp)
8010244f:	e8 9e f5 ff ff       	call   801019f2 <ilock>
80102454:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010245e:	66 83 f8 01          	cmp    $0x1,%ax
80102462:	74 18                	je     8010247c <namex+0x76>
      iunlockput(ip);
80102464:	83 ec 0c             	sub    $0xc,%esp
80102467:	ff 75 f4             	push   -0xc(%ebp)
8010246a:	e8 b4 f7 ff ff       	call   80101c23 <iunlockput>
8010246f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102472:	b8 00 00 00 00       	mov    $0x0,%eax
80102477:	e9 a7 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010247c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102480:	74 20                	je     801024a2 <namex+0x9c>
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	0f b6 00             	movzbl (%eax),%eax
80102488:	84 c0                	test   %al,%al
8010248a:	75 16                	jne    801024a2 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010248c:	83 ec 0c             	sub    $0xc,%esp
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 6e f6 ff ff       	call   80101b05 <iunlock>
80102497:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249d:	e9 81 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	6a 00                	push   $0x0
801024a7:	ff 75 10             	push   0x10(%ebp)
801024aa:	ff 75 f4             	push   -0xc(%ebp)
801024ad:	e8 22 fd ff ff       	call   801021d4 <dirlookup>
801024b2:	83 c4 10             	add    $0x10,%esp
801024b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bc:	75 15                	jne    801024d3 <namex+0xcd>
      iunlockput(ip);
801024be:	83 ec 0c             	sub    $0xc,%esp
801024c1:	ff 75 f4             	push   -0xc(%ebp)
801024c4:	e8 5a f7 ff ff       	call   80101c23 <iunlockput>
801024c9:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cc:	b8 00 00 00 00       	mov    $0x0,%eax
801024d1:	eb 50                	jmp    80102523 <namex+0x11d>
    }
    iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 45 f7 ff ff       	call   80101c23 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e7:	83 ec 08             	sub    $0x8,%esp
801024ea:	ff 75 10             	push   0x10(%ebp)
801024ed:	ff 75 08             	push   0x8(%ebp)
801024f0:	e8 71 fe ff ff       	call   80102366 <skipelem>
801024f5:	83 c4 10             	add    $0x10,%esp
801024f8:	89 45 08             	mov    %eax,0x8(%ebp)
801024fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ff:	0f 85 44 ff ff ff    	jne    80102449 <namex+0x43>
  }
  if(nameiparent){
80102505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102509:	74 15                	je     80102520 <namex+0x11a>
    iput(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	push   -0xc(%ebp)
80102511:	e8 3d f6 ff ff       	call   80101b53 <iput>
80102516:	83 c4 10             	add    $0x10,%esp
    return 0;
80102519:	b8 00 00 00 00       	mov    $0x0,%eax
8010251e:	eb 03                	jmp    80102523 <namex+0x11d>
  }
  return ip;
80102520:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102523:	c9                   	leave
80102524:	c3                   	ret

80102525 <namei>:

struct inode*
namei(char *path)
{
80102525:	55                   	push   %ebp
80102526:	89 e5                	mov    %esp,%ebp
80102528:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252b:	83 ec 04             	sub    $0x4,%esp
8010252e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102531:	50                   	push   %eax
80102532:	6a 00                	push   $0x0
80102534:	ff 75 08             	push   0x8(%ebp)
80102537:	e8 ca fe ff ff       	call   80102406 <namex>
8010253c:	83 c4 10             	add    $0x10,%esp
}
8010253f:	c9                   	leave
80102540:	c3                   	ret

80102541 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102541:	55                   	push   %ebp
80102542:	89 e5                	mov    %esp,%ebp
80102544:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102547:	83 ec 04             	sub    $0x4,%esp
8010254a:	ff 75 0c             	push   0xc(%ebp)
8010254d:	6a 01                	push   $0x1
8010254f:	ff 75 08             	push   0x8(%ebp)
80102552:	e8 af fe ff ff       	call   80102406 <namex>
80102557:	83 c4 10             	add    $0x10,%esp
}
8010255a:	c9                   	leave
8010255b:	c3                   	ret

8010255c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010255f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102564:	8b 55 08             	mov    0x8(%ebp),%edx
80102567:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102569:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102571:	5d                   	pop    %ebp
80102572:	c3                   	ret

80102573 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102573:	55                   	push   %ebp
80102574:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102576:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257b:	8b 55 08             	mov    0x8(%ebp),%edx
8010257e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102580:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102585:	8b 55 0c             	mov    0xc(%ebp),%edx
80102588:	89 50 10             	mov    %edx,0x10(%eax)
}
8010258b:	90                   	nop
8010258c:	5d                   	pop    %ebp
8010258d:	c3                   	ret

8010258e <ioapicinit>:

void
ioapicinit(void)
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102594:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
8010259b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010259e:	6a 01                	push   $0x1
801025a0:	e8 b7 ff ff ff       	call   8010255c <ioapicread>
801025a5:	83 c4 04             	add    $0x4,%esp
801025a8:	c1 e8 10             	shr    $0x10,%eax
801025ab:	25 ff 00 00 00       	and    $0xff,%eax
801025b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025b3:	6a 00                	push   $0x0
801025b5:	e8 a2 ff ff ff       	call   8010255c <ioapicread>
801025ba:	83 c4 04             	add    $0x4,%esp
801025bd:	c1 e8 18             	shr    $0x18,%eax
801025c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025c3:	0f b6 05 44 6c 19 80 	movzbl 0x80196c44,%eax
801025ca:	0f b6 c0             	movzbl %al,%eax
801025cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d0:	74 10                	je     801025e2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	68 2c a3 10 80       	push   $0x8010a32c
801025da:	e8 15 de ff ff       	call   801003f4 <cprintf>
801025df:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e9:	eb 3f                	jmp    8010262a <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	83 c0 20             	add    $0x20,%eax
801025f1:	0d 00 00 01 00       	or     $0x10000,%eax
801025f6:	89 c2                	mov    %eax,%edx
801025f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fb:	83 c0 08             	add    $0x8,%eax
801025fe:	01 c0                	add    %eax,%eax
80102600:	83 ec 08             	sub    $0x8,%esp
80102603:	52                   	push   %edx
80102604:	50                   	push   %eax
80102605:	e8 69 ff ff ff       	call   80102573 <ioapicwrite>
8010260a:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102610:	83 c0 08             	add    $0x8,%eax
80102613:	01 c0                	add    %eax,%eax
80102615:	83 c0 01             	add    $0x1,%eax
80102618:	83 ec 08             	sub    $0x8,%esp
8010261b:	6a 00                	push   $0x0
8010261d:	50                   	push   %eax
8010261e:	e8 50 ff ff ff       	call   80102573 <ioapicwrite>
80102623:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102626:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010262a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102630:	7e b9                	jle    801025eb <ioapicinit+0x5d>
  }
}
80102632:	90                   	nop
80102633:	90                   	nop
80102634:	c9                   	leave
80102635:	c3                   	ret

80102636 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102636:	55                   	push   %ebp
80102637:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 20             	add    $0x20,%eax
8010263f:	89 c2                	mov    %eax,%edx
80102641:	8b 45 08             	mov    0x8(%ebp),%eax
80102644:	83 c0 08             	add    $0x8,%eax
80102647:	01 c0                	add    %eax,%eax
80102649:	52                   	push   %edx
8010264a:	50                   	push   %eax
8010264b:	e8 23 ff ff ff       	call   80102573 <ioapicwrite>
80102650:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102653:	8b 45 0c             	mov    0xc(%ebp),%eax
80102656:	c1 e0 18             	shl    $0x18,%eax
80102659:	89 c2                	mov    %eax,%edx
8010265b:	8b 45 08             	mov    0x8(%ebp),%eax
8010265e:	83 c0 08             	add    $0x8,%eax
80102661:	01 c0                	add    %eax,%eax
80102663:	83 c0 01             	add    $0x1,%eax
80102666:	52                   	push   %edx
80102667:	50                   	push   %eax
80102668:	e8 06 ff ff ff       	call   80102573 <ioapicwrite>
8010266d:	83 c4 08             	add    $0x8,%esp
}
80102670:	90                   	nop
80102671:	c9                   	leave
80102672:	c3                   	ret

80102673 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102673:	55                   	push   %ebp
80102674:	89 e5                	mov    %esp,%ebp
80102676:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102679:	83 ec 08             	sub    $0x8,%esp
8010267c:	68 5e a3 10 80       	push   $0x8010a35e
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 5e 21 00 00       	call   801047e9 <initlock>
8010268b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010268e:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
80102695:	00 00 00 
  freerange(vstart, vend);
80102698:	83 ec 08             	sub    $0x8,%esp
8010269b:	ff 75 0c             	push   0xc(%ebp)
8010269e:	ff 75 08             	push   0x8(%ebp)
801026a1:	e8 2a 00 00 00       	call   801026d0 <freerange>
801026a6:	83 c4 10             	add    $0x10,%esp
}
801026a9:	90                   	nop
801026aa:	c9                   	leave
801026ab:	c3                   	ret

801026ac <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026ac:	55                   	push   %ebp
801026ad:	89 e5                	mov    %esp,%ebp
801026af:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026b2:	83 ec 08             	sub    $0x8,%esp
801026b5:	ff 75 0c             	push   0xc(%ebp)
801026b8:	ff 75 08             	push   0x8(%ebp)
801026bb:	e8 10 00 00 00       	call   801026d0 <freerange>
801026c0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026c3:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026ca:	00 00 00 
}
801026cd:	90                   	nop
801026ce:	c9                   	leave
801026cf:	c3                   	ret

801026d0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026d6:	8b 45 08             	mov    0x8(%ebp),%eax
801026d9:	05 ff 0f 00 00       	add    $0xfff,%eax
801026de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e6:	eb 15                	jmp    801026fd <freerange+0x2d>
    kfree(p);
801026e8:	83 ec 0c             	sub    $0xc,%esp
801026eb:	ff 75 f4             	push   -0xc(%ebp)
801026ee:	e8 1b 00 00 00       	call   8010270e <kfree>
801026f3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026f6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102700:	05 00 10 00 00       	add    $0x1000,%eax
80102705:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102708:	73 de                	jae    801026e8 <freerange+0x18>
}
8010270a:	90                   	nop
8010270b:	90                   	nop
8010270c:	c9                   	leave
8010270d:	c3                   	ret

8010270e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010270e:	55                   	push   %ebp
8010270f:	89 e5                	mov    %esp,%ebp
80102711:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	25 ff 0f 00 00       	and    $0xfff,%eax
8010271c:	85 c0                	test   %eax,%eax
8010271e:	75 18                	jne    80102738 <kfree+0x2a>
80102720:	81 7d 08 00 80 19 80 	cmpl   $0x80198000,0x8(%ebp)
80102727:	72 0f                	jb     80102738 <kfree+0x2a>
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	05 00 00 00 80       	add    $0x80000000,%eax
80102731:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102736:	76 0d                	jbe    80102745 <kfree+0x37>
    panic("kfree");
80102738:	83 ec 0c             	sub    $0xc,%esp
8010273b:	68 63 a3 10 80       	push   $0x8010a363
80102740:	e8 7c de ff ff       	call   801005c1 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 2a 23 00 00       	call   80104a81 <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 9b 20 00 00       	call   8010480b <acquire>
80102770:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102779:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
8010277f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102782:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102787:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
8010278c:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102791:	85 c0                	test   %eax,%eax
80102793:	74 10                	je     801027a5 <kfree+0x97>
    release(&kmem.lock);
80102795:	83 ec 0c             	sub    $0xc,%esp
80102798:	68 c0 40 19 80       	push   $0x801940c0
8010279d:	e8 d7 20 00 00       	call   80104879 <release>
801027a2:	83 c4 10             	add    $0x10,%esp
}
801027a5:	90                   	nop
801027a6:	c9                   	leave
801027a7:	c3                   	ret

801027a8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a8:	55                   	push   %ebp
801027a9:	89 e5                	mov    %esp,%ebp
801027ab:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027ae:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027b3:	85 c0                	test   %eax,%eax
801027b5:	74 10                	je     801027c7 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b7:	83 ec 0c             	sub    $0xc,%esp
801027ba:	68 c0 40 19 80       	push   $0x801940c0
801027bf:	e8 47 20 00 00       	call   8010480b <acquire>
801027c4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c7:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d3:	74 0a                	je     801027df <kalloc+0x37>
    kmem.freelist = r->next;
801027d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d8:	8b 00                	mov    (%eax),%eax
801027da:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027df:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027e4:	85 c0                	test   %eax,%eax
801027e6:	74 10                	je     801027f8 <kalloc+0x50>
    release(&kmem.lock);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	68 c0 40 19 80       	push   $0x801940c0
801027f0:	e8 84 20 00 00       	call   80104879 <release>
801027f5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027fb:	c9                   	leave
801027fc:	c3                   	ret

801027fd <inb>:
{
801027fd:	55                   	push   %ebp
801027fe:	89 e5                	mov    %esp,%ebp
80102800:	83 ec 14             	sub    $0x14,%esp
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010280a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010280e:	89 c2                	mov    %eax,%edx
80102810:	ec                   	in     (%dx),%al
80102811:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102814:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102818:	c9                   	leave
80102819:	c3                   	ret

8010281a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010281a:	55                   	push   %ebp
8010281b:	89 e5                	mov    %esp,%ebp
8010281d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102820:	6a 64                	push   $0x64
80102822:	e8 d6 ff ff ff       	call   801027fd <inb>
80102827:	83 c4 04             	add    $0x4,%esp
8010282a:	0f b6 c0             	movzbl %al,%eax
8010282d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102833:	83 e0 01             	and    $0x1,%eax
80102836:	85 c0                	test   %eax,%eax
80102838:	75 0a                	jne    80102844 <kbdgetc+0x2a>
    return -1;
8010283a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010283f:	e9 23 01 00 00       	jmp    80102967 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102844:	6a 60                	push   $0x60
80102846:	e8 b2 ff ff ff       	call   801027fd <inb>
8010284b:	83 c4 04             	add    $0x4,%esp
8010284e:	0f b6 c0             	movzbl %al,%eax
80102851:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102854:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010285b:	75 17                	jne    80102874 <kbdgetc+0x5a>
    shift |= E0ESC;
8010285d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102862:	83 c8 40             	or     $0x40,%eax
80102865:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
8010286a:	b8 00 00 00 00       	mov    $0x0,%eax
8010286f:	e9 f3 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102877:	25 80 00 00 00       	and    $0x80,%eax
8010287c:	85 c0                	test   %eax,%eax
8010287e:	74 45                	je     801028c5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102880:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102885:	83 e0 40             	and    $0x40,%eax
80102888:	85 c0                	test   %eax,%eax
8010288a:	75 08                	jne    80102894 <kbdgetc+0x7a>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	83 e0 7f             	and    $0x7f,%eax
80102892:	eb 03                	jmp    80102897 <kbdgetc+0x7d>
80102894:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102897:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010289a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010289d:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028a2:	0f b6 00             	movzbl (%eax),%eax
801028a5:	83 c8 40             	or     $0x40,%eax
801028a8:	0f b6 c0             	movzbl %al,%eax
801028ab:	f7 d0                	not    %eax
801028ad:	89 c2                	mov    %eax,%edx
801028af:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028b4:	21 d0                	and    %edx,%eax
801028b6:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028bb:	b8 00 00 00 00       	mov    $0x0,%eax
801028c0:	e9 a2 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028c5:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ca:	83 e0 40             	and    $0x40,%eax
801028cd:	85 c0                	test   %eax,%eax
801028cf:	74 14                	je     801028e5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028d1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028dd:	83 e0 bf             	and    $0xffffffbf,%eax
801028e0:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e8:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028ed:	0f b6 00             	movzbl (%eax),%eax
801028f0:	0f b6 d0             	movzbl %al,%edx
801028f3:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f8:	09 d0                	or     %edx,%eax
801028fa:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102902:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102907:	0f b6 00             	movzbl (%eax),%eax
8010290a:	0f b6 d0             	movzbl %al,%edx
8010290d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102912:	31 d0                	xor    %edx,%eax
80102914:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102919:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010291e:	83 e0 03             	and    $0x3,%eax
80102921:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102928:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010292b:	01 d0                	add    %edx,%eax
8010292d:	0f b6 00             	movzbl (%eax),%eax
80102930:	0f b6 c0             	movzbl %al,%eax
80102933:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102936:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010293b:	83 e0 08             	and    $0x8,%eax
8010293e:	85 c0                	test   %eax,%eax
80102940:	74 22                	je     80102964 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102942:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102946:	76 0c                	jbe    80102954 <kbdgetc+0x13a>
80102948:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010294c:	77 06                	ja     80102954 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010294e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102952:	eb 10                	jmp    80102964 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102954:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102958:	76 0a                	jbe    80102964 <kbdgetc+0x14a>
8010295a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010295e:	77 04                	ja     80102964 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102960:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102964:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102967:	c9                   	leave
80102968:	c3                   	ret

80102969 <kbdintr>:

void
kbdintr(void)
{
80102969:	55                   	push   %ebp
8010296a:	89 e5                	mov    %esp,%ebp
8010296c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010296f:	83 ec 0c             	sub    $0xc,%esp
80102972:	68 1a 28 10 80       	push   $0x8010281a
80102977:	e8 72 de ff ff       	call   801007ee <consoleintr>
8010297c:	83 c4 10             	add    $0x10,%esp
}
8010297f:	90                   	nop
80102980:	c9                   	leave
80102981:	c3                   	ret

80102982 <inb>:
{
80102982:	55                   	push   %ebp
80102983:	89 e5                	mov    %esp,%ebp
80102985:	83 ec 14             	sub    $0x14,%esp
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010298f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102993:	89 c2                	mov    %eax,%edx
80102995:	ec                   	in     (%dx),%al
80102996:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102999:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010299d:	c9                   	leave
8010299e:	c3                   	ret

8010299f <outb>:
{
8010299f:	55                   	push   %ebp
801029a0:	89 e5                	mov    %esp,%ebp
801029a2:	83 ec 08             	sub    $0x8,%esp
801029a5:	8b 55 08             	mov    0x8(%ebp),%edx
801029a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801029af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029ba:	ee                   	out    %al,(%dx)
}
801029bb:	90                   	nop
801029bc:	c9                   	leave
801029bd:	c3                   	ret

801029be <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029be:	55                   	push   %ebp
801029bf:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029c1:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c6:	8b 55 08             	mov    0x8(%ebp),%edx
801029c9:	c1 e2 02             	shl    $0x2,%edx
801029cc:	01 c2                	add    %eax,%edx
801029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801029d1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029d3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d8:	83 c0 20             	add    $0x20,%eax
801029db:	8b 00                	mov    (%eax),%eax
}
801029dd:	90                   	nop
801029de:	5d                   	pop    %ebp
801029df:	c3                   	ret

801029e0 <lapicinit>:

void
lapicinit(void)
{
801029e0:	55                   	push   %ebp
801029e1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029e3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e8:	85 c0                	test   %eax,%eax
801029ea:	0f 84 09 01 00 00    	je     80102af9 <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029f0:	68 3f 01 00 00       	push   $0x13f
801029f5:	6a 3c                	push   $0x3c
801029f7:	e8 c2 ff ff ff       	call   801029be <lapicw>
801029fc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029ff:	6a 0b                	push   $0xb
80102a01:	68 f8 00 00 00       	push   $0xf8
80102a06:	e8 b3 ff ff ff       	call   801029be <lapicw>
80102a0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a0e:	68 20 00 02 00       	push   $0x20020
80102a13:	68 c8 00 00 00       	push   $0xc8
80102a18:	e8 a1 ff ff ff       	call   801029be <lapicw>
80102a1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a20:	68 80 96 98 00       	push   $0x989680
80102a25:	68 e0 00 00 00       	push   $0xe0
80102a2a:	e8 8f ff ff ff       	call   801029be <lapicw>
80102a2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a32:	68 00 00 01 00       	push   $0x10000
80102a37:	68 d4 00 00 00       	push   $0xd4
80102a3c:	e8 7d ff ff ff       	call   801029be <lapicw>
80102a41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a44:	68 00 00 01 00       	push   $0x10000
80102a49:	68 d8 00 00 00       	push   $0xd8
80102a4e:	e8 6b ff ff ff       	call   801029be <lapicw>
80102a53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a56:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a5b:	83 c0 30             	add    $0x30,%eax
80102a5e:	8b 00                	mov    (%eax),%eax
80102a60:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102a65:	85 c0                	test   %eax,%eax
80102a67:	74 12                	je     80102a7b <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102a69:	68 00 00 01 00       	push   $0x10000
80102a6e:	68 d0 00 00 00       	push   $0xd0
80102a73:	e8 46 ff ff ff       	call   801029be <lapicw>
80102a78:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a7b:	6a 33                	push   $0x33
80102a7d:	68 dc 00 00 00       	push   $0xdc
80102a82:	e8 37 ff ff ff       	call   801029be <lapicw>
80102a87:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a8a:	6a 00                	push   $0x0
80102a8c:	68 a0 00 00 00       	push   $0xa0
80102a91:	e8 28 ff ff ff       	call   801029be <lapicw>
80102a96:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a99:	6a 00                	push   $0x0
80102a9b:	68 a0 00 00 00       	push   $0xa0
80102aa0:	e8 19 ff ff ff       	call   801029be <lapicw>
80102aa5:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa8:	6a 00                	push   $0x0
80102aaa:	6a 2c                	push   $0x2c
80102aac:	e8 0d ff ff ff       	call   801029be <lapicw>
80102ab1:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab4:	6a 00                	push   $0x0
80102ab6:	68 c4 00 00 00       	push   $0xc4
80102abb:	e8 fe fe ff ff       	call   801029be <lapicw>
80102ac0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac3:	68 00 85 08 00       	push   $0x88500
80102ac8:	68 c0 00 00 00       	push   $0xc0
80102acd:	e8 ec fe ff ff       	call   801029be <lapicw>
80102ad2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad5:	90                   	nop
80102ad6:	a1 00 41 19 80       	mov    0x80194100,%eax
80102adb:	05 00 03 00 00       	add    $0x300,%eax
80102ae0:	8b 00                	mov    (%eax),%eax
80102ae2:	25 00 10 00 00       	and    $0x1000,%eax
80102ae7:	85 c0                	test   %eax,%eax
80102ae9:	75 eb                	jne    80102ad6 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102aeb:	6a 00                	push   $0x0
80102aed:	6a 20                	push   $0x20
80102aef:	e8 ca fe ff ff       	call   801029be <lapicw>
80102af4:	83 c4 08             	add    $0x8,%esp
80102af7:	eb 01                	jmp    80102afa <lapicinit+0x11a>
    return;
80102af9:	90                   	nop
}
80102afa:	c9                   	leave
80102afb:	c3                   	ret

80102afc <lapicid>:

int
lapicid(void)
{
80102afc:	55                   	push   %ebp
80102afd:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102aff:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b04:	85 c0                	test   %eax,%eax
80102b06:	75 07                	jne    80102b0f <lapicid+0x13>
    return 0;
80102b08:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0d:	eb 0d                	jmp    80102b1c <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b14:	83 c0 20             	add    $0x20,%eax
80102b17:	8b 00                	mov    (%eax),%eax
80102b19:	c1 e8 18             	shr    $0x18,%eax
}
80102b1c:	5d                   	pop    %ebp
80102b1d:	c3                   	ret

80102b1e <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1e:	55                   	push   %ebp
80102b1f:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b21:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b26:	85 c0                	test   %eax,%eax
80102b28:	74 0c                	je     80102b36 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b2a:	6a 00                	push   $0x0
80102b2c:	6a 2c                	push   $0x2c
80102b2e:	e8 8b fe ff ff       	call   801029be <lapicw>
80102b33:	83 c4 08             	add    $0x8,%esp
}
80102b36:	90                   	nop
80102b37:	c9                   	leave
80102b38:	c3                   	ret

80102b39 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b39:	55                   	push   %ebp
80102b3a:	89 e5                	mov    %esp,%ebp
}
80102b3c:	90                   	nop
80102b3d:	5d                   	pop    %ebp
80102b3e:	c3                   	ret

80102b3f <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3f:	55                   	push   %ebp
80102b40:	89 e5                	mov    %esp,%ebp
80102b42:	83 ec 14             	sub    $0x14,%esp
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b4b:	6a 0f                	push   $0xf
80102b4d:	6a 70                	push   $0x70
80102b4f:	e8 4b fe ff ff       	call   8010299f <outb>
80102b54:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b57:	6a 0a                	push   $0xa
80102b59:	6a 71                	push   $0x71
80102b5b:	e8 3f fe ff ff       	call   8010299f <outb>
80102b60:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b63:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b72:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b75:	c1 e8 04             	shr    $0x4,%eax
80102b78:	89 c2                	mov    %eax,%edx
80102b7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7d:	83 c0 02             	add    $0x2,%eax
80102b80:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b83:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b87:	c1 e0 18             	shl    $0x18,%eax
80102b8a:	50                   	push   %eax
80102b8b:	68 c4 00 00 00       	push   $0xc4
80102b90:	e8 29 fe ff ff       	call   801029be <lapicw>
80102b95:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b98:	68 00 c5 00 00       	push   $0xc500
80102b9d:	68 c0 00 00 00       	push   $0xc0
80102ba2:	e8 17 fe ff ff       	call   801029be <lapicw>
80102ba7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102baa:	68 c8 00 00 00       	push   $0xc8
80102baf:	e8 85 ff ff ff       	call   80102b39 <microdelay>
80102bb4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb7:	68 00 85 00 00       	push   $0x8500
80102bbc:	68 c0 00 00 00       	push   $0xc0
80102bc1:	e8 f8 fd ff ff       	call   801029be <lapicw>
80102bc6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc9:	6a 64                	push   $0x64
80102bcb:	e8 69 ff ff ff       	call   80102b39 <microdelay>
80102bd0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bda:	eb 3d                	jmp    80102c19 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bdc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102be0:	c1 e0 18             	shl    $0x18,%eax
80102be3:	50                   	push   %eax
80102be4:	68 c4 00 00 00       	push   $0xc4
80102be9:	e8 d0 fd ff ff       	call   801029be <lapicw>
80102bee:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf4:	c1 e8 0c             	shr    $0xc,%eax
80102bf7:	80 cc 06             	or     $0x6,%ah
80102bfa:	50                   	push   %eax
80102bfb:	68 c0 00 00 00       	push   $0xc0
80102c00:	e8 b9 fd ff ff       	call   801029be <lapicw>
80102c05:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c08:	68 c8 00 00 00       	push   $0xc8
80102c0d:	e8 27 ff ff ff       	call   80102b39 <microdelay>
80102c12:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c15:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c19:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1d:	7e bd                	jle    80102bdc <lapicstartap+0x9d>
  }
}
80102c1f:	90                   	nop
80102c20:	90                   	nop
80102c21:	c9                   	leave
80102c22:	c3                   	ret

80102c23 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c26:	8b 45 08             	mov    0x8(%ebp),%eax
80102c29:	0f b6 c0             	movzbl %al,%eax
80102c2c:	50                   	push   %eax
80102c2d:	6a 70                	push   $0x70
80102c2f:	e8 6b fd ff ff       	call   8010299f <outb>
80102c34:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c37:	68 c8 00 00 00       	push   $0xc8
80102c3c:	e8 f8 fe ff ff       	call   80102b39 <microdelay>
80102c41:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c44:	6a 71                	push   $0x71
80102c46:	e8 37 fd ff ff       	call   80102982 <inb>
80102c4b:	83 c4 04             	add    $0x4,%esp
80102c4e:	0f b6 c0             	movzbl %al,%eax
}
80102c51:	c9                   	leave
80102c52:	c3                   	ret

80102c53 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c53:	55                   	push   %ebp
80102c54:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c56:	6a 00                	push   $0x0
80102c58:	e8 c6 ff ff ff       	call   80102c23 <cmos_read>
80102c5d:	83 c4 04             	add    $0x4,%esp
80102c60:	8b 55 08             	mov    0x8(%ebp),%edx
80102c63:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c65:	6a 02                	push   $0x2
80102c67:	e8 b7 ff ff ff       	call   80102c23 <cmos_read>
80102c6c:	83 c4 04             	add    $0x4,%esp
80102c6f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c72:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c75:	6a 04                	push   $0x4
80102c77:	e8 a7 ff ff ff       	call   80102c23 <cmos_read>
80102c7c:	83 c4 04             	add    $0x4,%esp
80102c7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c82:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c85:	6a 07                	push   $0x7
80102c87:	e8 97 ff ff ff       	call   80102c23 <cmos_read>
80102c8c:	83 c4 04             	add    $0x4,%esp
80102c8f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c92:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c95:	6a 08                	push   $0x8
80102c97:	e8 87 ff ff ff       	call   80102c23 <cmos_read>
80102c9c:	83 c4 04             	add    $0x4,%esp
80102c9f:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca2:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca5:	6a 09                	push   $0x9
80102ca7:	e8 77 ff ff ff       	call   80102c23 <cmos_read>
80102cac:	83 c4 04             	add    $0x4,%esp
80102caf:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb2:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb5:	90                   	nop
80102cb6:	c9                   	leave
80102cb7:	c3                   	ret

80102cb8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbe:	6a 0b                	push   $0xb
80102cc0:	e8 5e ff ff ff       	call   80102c23 <cmos_read>
80102cc5:	83 c4 04             	add    $0x4,%esp
80102cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cce:	83 e0 04             	and    $0x4,%eax
80102cd1:	85 c0                	test   %eax,%eax
80102cd3:	0f 94 c0             	sete   %al
80102cd6:	0f b6 c0             	movzbl %al,%eax
80102cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cdc:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdf:	50                   	push   %eax
80102ce0:	e8 6e ff ff ff       	call   80102c53 <fill_rtcdate>
80102ce5:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce8:	6a 0a                	push   $0xa
80102cea:	e8 34 ff ff ff       	call   80102c23 <cmos_read>
80102cef:	83 c4 04             	add    $0x4,%esp
80102cf2:	25 80 00 00 00       	and    $0x80,%eax
80102cf7:	85 c0                	test   %eax,%eax
80102cf9:	75 27                	jne    80102d22 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cfb:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfe:	50                   	push   %eax
80102cff:	e8 4f ff ff ff       	call   80102c53 <fill_rtcdate>
80102d04:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d07:	83 ec 04             	sub    $0x4,%esp
80102d0a:	6a 18                	push   $0x18
80102d0c:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0f:	50                   	push   %eax
80102d10:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d13:	50                   	push   %eax
80102d14:	e8 cf 1d 00 00       	call   80104ae8 <memcmp>
80102d19:	83 c4 10             	add    $0x10,%esp
80102d1c:	85 c0                	test   %eax,%eax
80102d1e:	74 05                	je     80102d25 <cmostime+0x6d>
80102d20:	eb ba                	jmp    80102cdc <cmostime+0x24>
        continue;
80102d22:	90                   	nop
    fill_rtcdate(&t1);
80102d23:	eb b7                	jmp    80102cdc <cmostime+0x24>
      break;
80102d25:	90                   	nop
  }

  // convert
  if(bcd) {
80102d26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d2a:	0f 84 b4 00 00 00    	je     80102de4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d30:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d33:	c1 e8 04             	shr    $0x4,%eax
80102d36:	89 c2                	mov    %eax,%edx
80102d38:	89 d0                	mov    %edx,%eax
80102d3a:	c1 e0 02             	shl    $0x2,%eax
80102d3d:	01 d0                	add    %edx,%eax
80102d3f:	01 c0                	add    %eax,%eax
80102d41:	89 c2                	mov    %eax,%edx
80102d43:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d46:	83 e0 0f             	and    $0xf,%eax
80102d49:	01 d0                	add    %edx,%eax
80102d4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d51:	c1 e8 04             	shr    $0x4,%eax
80102d54:	89 c2                	mov    %eax,%edx
80102d56:	89 d0                	mov    %edx,%eax
80102d58:	c1 e0 02             	shl    $0x2,%eax
80102d5b:	01 d0                	add    %edx,%eax
80102d5d:	01 c0                	add    %eax,%eax
80102d5f:	89 c2                	mov    %eax,%edx
80102d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d64:	83 e0 0f             	and    $0xf,%eax
80102d67:	01 d0                	add    %edx,%eax
80102d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6f:	c1 e8 04             	shr    $0x4,%eax
80102d72:	89 c2                	mov    %eax,%edx
80102d74:	89 d0                	mov    %edx,%eax
80102d76:	c1 e0 02             	shl    $0x2,%eax
80102d79:	01 d0                	add    %edx,%eax
80102d7b:	01 c0                	add    %eax,%eax
80102d7d:	89 c2                	mov    %eax,%edx
80102d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d82:	83 e0 0f             	and    $0xf,%eax
80102d85:	01 d0                	add    %edx,%eax
80102d87:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8d:	c1 e8 04             	shr    $0x4,%eax
80102d90:	89 c2                	mov    %eax,%edx
80102d92:	89 d0                	mov    %edx,%eax
80102d94:	c1 e0 02             	shl    $0x2,%eax
80102d97:	01 d0                	add    %edx,%eax
80102d99:	01 c0                	add    %eax,%eax
80102d9b:	89 c2                	mov    %eax,%edx
80102d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102da0:	83 e0 0f             	and    $0xf,%eax
80102da3:	01 d0                	add    %edx,%eax
80102da5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dab:	c1 e8 04             	shr    $0x4,%eax
80102dae:	89 c2                	mov    %eax,%edx
80102db0:	89 d0                	mov    %edx,%eax
80102db2:	c1 e0 02             	shl    $0x2,%eax
80102db5:	01 d0                	add    %edx,%eax
80102db7:	01 c0                	add    %eax,%eax
80102db9:	89 c2                	mov    %eax,%edx
80102dbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbe:	83 e0 0f             	and    $0xf,%eax
80102dc1:	01 d0                	add    %edx,%eax
80102dc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc9:	c1 e8 04             	shr    $0x4,%eax
80102dcc:	89 c2                	mov    %eax,%edx
80102dce:	89 d0                	mov    %edx,%eax
80102dd0:	c1 e0 02             	shl    $0x2,%eax
80102dd3:	01 d0                	add    %edx,%eax
80102dd5:	01 c0                	add    %eax,%eax
80102dd7:	89 c2                	mov    %eax,%edx
80102dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ddc:	83 e0 0f             	and    $0xf,%eax
80102ddf:	01 d0                	add    %edx,%eax
80102de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de4:	8b 45 08             	mov    0x8(%ebp),%eax
80102de7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dea:	89 10                	mov    %edx,(%eax)
80102dec:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102def:	89 50 04             	mov    %edx,0x4(%eax)
80102df2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df5:	89 50 08             	mov    %edx,0x8(%eax)
80102df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dfb:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e01:	89 50 10             	mov    %edx,0x10(%eax)
80102e04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e07:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0d:	8b 40 14             	mov    0x14(%eax),%eax
80102e10:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e16:	8b 45 08             	mov    0x8(%ebp),%eax
80102e19:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1c:	90                   	nop
80102e1d:	c9                   	leave
80102e1e:	c3                   	ret

80102e1f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1f:	55                   	push   %ebp
80102e20:	89 e5                	mov    %esp,%ebp
80102e22:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e25:	83 ec 08             	sub    $0x8,%esp
80102e28:	68 69 a3 10 80       	push   $0x8010a369
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 b2 19 00 00       	call   801047e9 <initlock>
80102e37:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e3a:	83 ec 08             	sub    $0x8,%esp
80102e3d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e40:	50                   	push   %eax
80102e41:	ff 75 08             	push   0x8(%ebp)
80102e44:	e8 8f e5 ff ff       	call   801013d8 <readsb>
80102e49:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4f:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e57:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5f:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e64:	e8 b3 01 00 00       	call   8010301c <recover_from_log>
}
80102e69:	90                   	nop
80102e6a:	c9                   	leave
80102e6b:	c3                   	ret

80102e6c <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6c:	55                   	push   %ebp
80102e6d:	89 e5                	mov    %esp,%ebp
80102e6f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e79:	e9 95 00 00 00       	jmp    80102f13 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e87:	01 d0                	add    %edx,%eax
80102e89:	83 c0 01             	add    $0x1,%eax
80102e8c:	89 c2                	mov    %eax,%edx
80102e8e:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e93:	83 ec 08             	sub    $0x8,%esp
80102e96:	52                   	push   %edx
80102e97:	50                   	push   %eax
80102e98:	e8 64 d3 ff ff       	call   80100201 <bread>
80102e9d:	83 c4 10             	add    $0x10,%esp
80102ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea6:	83 c0 10             	add    $0x10,%eax
80102ea9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eb0:	89 c2                	mov    %eax,%edx
80102eb2:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb7:	83 ec 08             	sub    $0x8,%esp
80102eba:	52                   	push   %edx
80102ebb:	50                   	push   %eax
80102ebc:	e8 40 d3 ff ff       	call   80100201 <bread>
80102ec1:	83 c4 10             	add    $0x10,%esp
80102ec4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eca:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ed0:	83 c0 5c             	add    $0x5c,%eax
80102ed3:	83 ec 04             	sub    $0x4,%esp
80102ed6:	68 00 02 00 00       	push   $0x200
80102edb:	52                   	push   %edx
80102edc:	50                   	push   %eax
80102edd:	e8 5e 1c 00 00       	call   80104b40 <memmove>
80102ee2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee5:	83 ec 0c             	sub    $0xc,%esp
80102ee8:	ff 75 ec             	push   -0x14(%ebp)
80102eeb:	e8 4a d3 ff ff       	call   8010023a <bwrite>
80102ef0:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	ff 75 f0             	push   -0x10(%ebp)
80102ef9:	e8 85 d3 ff ff       	call   80100283 <brelse>
80102efe:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f01:	83 ec 0c             	sub    $0xc,%esp
80102f04:	ff 75 ec             	push   -0x14(%ebp)
80102f07:	e8 77 d3 ff ff       	call   80100283 <brelse>
80102f0c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f13:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f18:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f1b:	0f 8c 5d ff ff ff    	jl     80102e7e <install_trans+0x12>
  }
}
80102f21:	90                   	nop
80102f22:	90                   	nop
80102f23:	c9                   	leave
80102f24:	c3                   	ret

80102f25 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f25:	55                   	push   %ebp
80102f26:	89 e5                	mov    %esp,%ebp
80102f28:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f2b:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f30:	89 c2                	mov    %eax,%edx
80102f32:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f37:	83 ec 08             	sub    $0x8,%esp
80102f3a:	52                   	push   %edx
80102f3b:	50                   	push   %eax
80102f3c:	e8 c0 d2 ff ff       	call   80100201 <bread>
80102f41:	83 c4 10             	add    $0x10,%esp
80102f44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f4a:	83 c0 5c             	add    $0x5c,%eax
80102f4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f53:	8b 00                	mov    (%eax),%eax
80102f55:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f61:	eb 1b                	jmp    80102f7e <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f69:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f70:	83 c2 10             	add    $0x10,%edx
80102f73:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7e:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f83:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f86:	7c db                	jl     80102f63 <read_head+0x3e>
  }
  brelse(buf);
80102f88:	83 ec 0c             	sub    $0xc,%esp
80102f8b:	ff 75 f0             	push   -0x10(%ebp)
80102f8e:	e8 f0 d2 ff ff       	call   80100283 <brelse>
80102f93:	83 c4 10             	add    $0x10,%esp
}
80102f96:	90                   	nop
80102f97:	c9                   	leave
80102f98:	c3                   	ret

80102f99 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f99:	55                   	push   %ebp
80102f9a:	89 e5                	mov    %esp,%ebp
80102f9c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9f:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa4:	89 c2                	mov    %eax,%edx
80102fa6:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fab:	83 ec 08             	sub    $0x8,%esp
80102fae:	52                   	push   %edx
80102faf:	50                   	push   %eax
80102fb0:	e8 4c d2 ff ff       	call   80100201 <bread>
80102fb5:	83 c4 10             	add    $0x10,%esp
80102fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbe:	83 c0 5c             	add    $0x5c,%eax
80102fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc4:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcd:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd6:	eb 1b                	jmp    80102ff3 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdb:	83 c0 10             	add    $0x10,%eax
80102fde:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102feb:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff3:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ffb:	7c db                	jl     80102fd8 <write_head+0x3f>
  }
  bwrite(buf);
80102ffd:	83 ec 0c             	sub    $0xc,%esp
80103000:	ff 75 f0             	push   -0x10(%ebp)
80103003:	e8 32 d2 ff ff       	call   8010023a <bwrite>
80103008:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010300b:	83 ec 0c             	sub    $0xc,%esp
8010300e:	ff 75 f0             	push   -0x10(%ebp)
80103011:	e8 6d d2 ff ff       	call   80100283 <brelse>
80103016:	83 c4 10             	add    $0x10,%esp
}
80103019:	90                   	nop
8010301a:	c9                   	leave
8010301b:	c3                   	ret

8010301c <recover_from_log>:

static void
recover_from_log(void)
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
8010301f:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103022:	e8 fe fe ff ff       	call   80102f25 <read_head>
  install_trans(); // if committed, copy from log to disk
80103027:	e8 40 fe ff ff       	call   80102e6c <install_trans>
  log.lh.n = 0;
8010302c:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103033:	00 00 00 
  write_head(); // clear the log
80103036:	e8 5e ff ff ff       	call   80102f99 <write_head>
}
8010303b:	90                   	nop
8010303c:	c9                   	leave
8010303d:	c3                   	ret

8010303e <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303e:	55                   	push   %ebp
8010303f:	89 e5                	mov    %esp,%ebp
80103041:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103044:	83 ec 0c             	sub    $0xc,%esp
80103047:	68 20 41 19 80       	push   $0x80194120
8010304c:	e8 ba 17 00 00       	call   8010480b <acquire>
80103051:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103054:	a1 60 41 19 80       	mov    0x80194160,%eax
80103059:	85 c0                	test   %eax,%eax
8010305b:	74 17                	je     80103074 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305d:	83 ec 08             	sub    $0x8,%esp
80103060:	68 20 41 19 80       	push   $0x80194120
80103065:	68 20 41 19 80       	push   $0x80194120
8010306a:	e8 6a 12 00 00       	call   801042d9 <sleep>
8010306f:	83 c4 10             	add    $0x10,%esp
80103072:	eb e0                	jmp    80103054 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103074:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
8010307a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307f:	8d 50 01             	lea    0x1(%eax),%edx
80103082:	89 d0                	mov    %edx,%eax
80103084:	c1 e0 02             	shl    $0x2,%eax
80103087:	01 d0                	add    %edx,%eax
80103089:	01 c0                	add    %eax,%eax
8010308b:	01 c8                	add    %ecx,%eax
8010308d:	83 f8 1e             	cmp    $0x1e,%eax
80103090:	7e 17                	jle    801030a9 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103092:	83 ec 08             	sub    $0x8,%esp
80103095:	68 20 41 19 80       	push   $0x80194120
8010309a:	68 20 41 19 80       	push   $0x80194120
8010309f:	e8 35 12 00 00       	call   801042d9 <sleep>
801030a4:	83 c4 10             	add    $0x10,%esp
801030a7:	eb ab                	jmp    80103054 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a9:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ae:	83 c0 01             	add    $0x1,%eax
801030b1:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b6:	83 ec 0c             	sub    $0xc,%esp
801030b9:	68 20 41 19 80       	push   $0x80194120
801030be:	e8 b6 17 00 00       	call   80104879 <release>
801030c3:	83 c4 10             	add    $0x10,%esp
      break;
801030c6:	90                   	nop
    }
  }
}
801030c7:	90                   	nop
801030c8:	c9                   	leave
801030c9:	c3                   	ret

801030ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030ca:	55                   	push   %ebp
801030cb:	89 e5                	mov    %esp,%ebp
801030cd:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d7:	83 ec 0c             	sub    $0xc,%esp
801030da:	68 20 41 19 80       	push   $0x80194120
801030df:	e8 27 17 00 00       	call   8010480b <acquire>
801030e4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ec:	83 e8 01             	sub    $0x1,%eax
801030ef:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f4:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f9:	85 c0                	test   %eax,%eax
801030fb:	74 0d                	je     8010310a <end_op+0x40>
    panic("log.committing");
801030fd:	83 ec 0c             	sub    $0xc,%esp
80103100:	68 6d a3 10 80       	push   $0x8010a36d
80103105:	e8 b7 d4 ff ff       	call   801005c1 <panic>
  if(log.outstanding == 0){
8010310a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310f:	85 c0                	test   %eax,%eax
80103111:	75 13                	jne    80103126 <end_op+0x5c>
    do_commit = 1;
80103113:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010311a:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103121:	00 00 00 
80103124:	eb 10                	jmp    80103136 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103126:	83 ec 0c             	sub    $0xc,%esp
80103129:	68 20 41 19 80       	push   $0x80194120
8010312e:	e8 8d 12 00 00       	call   801043c0 <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 36 17 00 00       	call   80104879 <release>
80103143:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103146:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010314a:	74 3f                	je     8010318b <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314c:	e8 f6 00 00 00       	call   80103247 <commit>
    acquire(&log.lock);
80103151:	83 ec 0c             	sub    $0xc,%esp
80103154:	68 20 41 19 80       	push   $0x80194120
80103159:	e8 ad 16 00 00       	call   8010480b <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 48 12 00 00       	call   801043c0 <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 f1 16 00 00       	call   80104879 <release>
80103188:	83 c4 10             	add    $0x10,%esp
  }
}
8010318b:	90                   	nop
8010318c:	c9                   	leave
8010318d:	c3                   	ret

8010318e <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318e:	55                   	push   %ebp
8010318f:	89 e5                	mov    %esp,%ebp
80103191:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319b:	e9 95 00 00 00       	jmp    80103235 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801031a0:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a9:	01 d0                	add    %edx,%eax
801031ab:	83 c0 01             	add    $0x1,%eax
801031ae:	89 c2                	mov    %eax,%edx
801031b0:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b5:	83 ec 08             	sub    $0x8,%esp
801031b8:	52                   	push   %edx
801031b9:	50                   	push   %eax
801031ba:	e8 42 d0 ff ff       	call   80100201 <bread>
801031bf:	83 c4 10             	add    $0x10,%esp
801031c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c8:	83 c0 10             	add    $0x10,%eax
801031cb:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d2:	89 c2                	mov    %eax,%edx
801031d4:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d9:	83 ec 08             	sub    $0x8,%esp
801031dc:	52                   	push   %edx
801031dd:	50                   	push   %eax
801031de:	e8 1e d0 ff ff       	call   80100201 <bread>
801031e3:	83 c4 10             	add    $0x10,%esp
801031e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ec:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f2:	83 c0 5c             	add    $0x5c,%eax
801031f5:	83 ec 04             	sub    $0x4,%esp
801031f8:	68 00 02 00 00       	push   $0x200
801031fd:	52                   	push   %edx
801031fe:	50                   	push   %eax
801031ff:	e8 3c 19 00 00       	call   80104b40 <memmove>
80103204:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103207:	83 ec 0c             	sub    $0xc,%esp
8010320a:	ff 75 f0             	push   -0x10(%ebp)
8010320d:	e8 28 d0 ff ff       	call   8010023a <bwrite>
80103212:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103215:	83 ec 0c             	sub    $0xc,%esp
80103218:	ff 75 ec             	push   -0x14(%ebp)
8010321b:	e8 63 d0 ff ff       	call   80100283 <brelse>
80103220:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103223:	83 ec 0c             	sub    $0xc,%esp
80103226:	ff 75 f0             	push   -0x10(%ebp)
80103229:	e8 55 d0 ff ff       	call   80100283 <brelse>
8010322e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103235:	a1 68 41 19 80       	mov    0x80194168,%eax
8010323a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323d:	0f 8c 5d ff ff ff    	jl     801031a0 <write_log+0x12>
  }
}
80103243:	90                   	nop
80103244:	90                   	nop
80103245:	c9                   	leave
80103246:	c3                   	ret

80103247 <commit>:

static void
commit()
{
80103247:	55                   	push   %ebp
80103248:	89 e5                	mov    %esp,%ebp
8010324a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103252:	85 c0                	test   %eax,%eax
80103254:	7e 1e                	jle    80103274 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103256:	e8 33 ff ff ff       	call   8010318e <write_log>
    write_head();    // Write header to disk -- the real commit
8010325b:	e8 39 fd ff ff       	call   80102f99 <write_head>
    install_trans(); // Now install writes to home locations
80103260:	e8 07 fc ff ff       	call   80102e6c <install_trans>
    log.lh.n = 0;
80103265:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326f:	e8 25 fd ff ff       	call   80102f99 <write_head>
  }
}
80103274:	90                   	nop
80103275:	c9                   	leave
80103276:	c3                   	ret

80103277 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103277:	55                   	push   %ebp
80103278:	89 e5                	mov    %esp,%ebp
8010327a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103282:	83 f8 1d             	cmp    $0x1d,%eax
80103285:	7f 12                	jg     80103299 <log_write+0x22>
80103287:	8b 15 68 41 19 80    	mov    0x80194168,%edx
8010328d:	a1 58 41 19 80       	mov    0x80194158,%eax
80103292:	83 e8 01             	sub    $0x1,%eax
80103295:	39 c2                	cmp    %eax,%edx
80103297:	7c 0d                	jl     801032a6 <log_write+0x2f>
    panic("too big a transaction");
80103299:	83 ec 0c             	sub    $0xc,%esp
8010329c:	68 7c a3 10 80       	push   $0x8010a37c
801032a1:	e8 1b d3 ff ff       	call   801005c1 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 92 a3 10 80       	push   $0x8010a392
801032b7:	e8 05 d3 ff ff       	call   801005c1 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 42 15 00 00       	call   8010480b <acquire>
801032c9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d3:	eb 1d                	jmp    801032f2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d8:	83 c0 10             	add    $0x10,%eax
801032db:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e2:	89 c2                	mov    %eax,%edx
801032e4:	8b 45 08             	mov    0x8(%ebp),%eax
801032e7:	8b 40 08             	mov    0x8(%eax),%eax
801032ea:	39 c2                	cmp    %eax,%edx
801032ec:	74 10                	je     801032fe <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f2:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032fa:	7c d9                	jl     801032d5 <log_write+0x5e>
801032fc:	eb 01                	jmp    801032ff <log_write+0x88>
      break;
801032fe:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	8b 40 08             	mov    0x8(%eax),%eax
80103305:	89 c2                	mov    %eax,%edx
80103307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330a:	83 c0 10             	add    $0x10,%eax
8010330d:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103314:	a1 68 41 19 80       	mov    0x80194168,%eax
80103319:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331c:	75 0d                	jne    8010332b <log_write+0xb4>
    log.lh.n++;
8010331e:	a1 68 41 19 80       	mov    0x80194168,%eax
80103323:	83 c0 01             	add    $0x1,%eax
80103326:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010332b:	8b 45 08             	mov    0x8(%ebp),%eax
8010332e:	8b 00                	mov    (%eax),%eax
80103330:	83 c8 04             	or     $0x4,%eax
80103333:	89 c2                	mov    %eax,%edx
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010333a:	83 ec 0c             	sub    $0xc,%esp
8010333d:	68 20 41 19 80       	push   $0x80194120
80103342:	e8 32 15 00 00       	call   80104879 <release>
80103347:	83 c4 10             	add    $0x10,%esp
}
8010334a:	90                   	nop
8010334b:	c9                   	leave
8010334c:	c3                   	ret

8010334d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334d:	55                   	push   %ebp
8010334e:	89 e5                	mov    %esp,%ebp
80103350:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103353:	8b 55 08             	mov    0x8(%ebp),%edx
80103356:	8b 45 0c             	mov    0xc(%ebp),%eax
80103359:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335c:	f0 87 02             	lock xchg %eax,(%edx)
8010335f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103365:	c9                   	leave
80103366:	c3                   	ret

80103367 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103367:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010336b:	83 e4 f0             	and    $0xfffffff0,%esp
8010336e:	ff 71 fc             	push   -0x4(%ecx)
80103371:	55                   	push   %ebp
80103372:	89 e5                	mov    %esp,%ebp
80103374:	51                   	push   %ecx
80103375:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103378:	e8 43 4b 00 00       	call   80107ec0 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 80 19 80       	push   $0x80198000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 5b 41 00 00       	call   801074f2 <kvmalloc>
  mpinit_uefi();
80103397:	e8 ed 48 00 00       	call   80107c89 <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 e3 3b 00 00       	call   80106f89 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 6c d7 ff ff       	call   80100b21 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 68 2f 00 00       	call   80106322 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 a5 2a 00 00       	call   80105e69 <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 18 6c 00 00       	call   80109feb <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 29 4d 00 00       	call   8010811b <pci_init>
  arp_scan();
801033f2:	e8 5e 5a 00 00       	call   80108e55 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f7:	e8 61 07 00 00       	call   80103b5d <userinit>

  mpmain();        // finish this processor's setup
801033fc:	e8 1a 00 00 00       	call   8010341b <mpmain>

80103401 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103401:	55                   	push   %ebp
80103402:	89 e5                	mov    %esp,%ebp
80103404:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103407:	e8 fe 40 00 00       	call   8010750a <switchkvm>
  seginit();
8010340c:	e8 78 3b 00 00       	call   80106f89 <seginit>
  lapicinit();
80103411:	e8 ca f5 ff ff       	call   801029e0 <lapicinit>
  mpmain();
80103416:	e8 00 00 00 00       	call   8010341b <mpmain>

8010341b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010341b:	55                   	push   %ebp
8010341c:	89 e5                	mov    %esp,%ebp
8010341e:	53                   	push   %ebx
8010341f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103422:	e8 76 05 00 00       	call   8010399d <cpuid>
80103427:	89 c3                	mov    %eax,%ebx
80103429:	e8 6f 05 00 00       	call   8010399d <cpuid>
8010342e:	83 ec 04             	sub    $0x4,%esp
80103431:	53                   	push   %ebx
80103432:	50                   	push   %eax
80103433:	68 ad a3 10 80       	push   $0x8010a3ad
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 9a 2b 00 00       	call   80105fdf <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 6e 05 00 00       	call   801039b8 <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 86 0c 00 00       	call   801040e8 <scheduler>

80103462 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103462:	55                   	push   %ebp
80103463:	89 e5                	mov    %esp,%ebp
80103465:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103468:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346f:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103474:	83 ec 04             	sub    $0x4,%esp
80103477:	50                   	push   %eax
80103478:	68 18 f5 10 80       	push   $0x8010f518
8010347d:	ff 75 f0             	push   -0x10(%ebp)
80103480:	e8 bb 16 00 00       	call   80104b40 <memmove>
80103485:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103488:	c7 45 f4 80 69 19 80 	movl   $0x80196980,-0xc(%ebp)
8010348f:	eb 79                	jmp    8010350a <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103491:	e8 22 05 00 00       	call   801039b8 <mycpu>
80103496:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103499:	74 67                	je     80103502 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010349b:	e8 08 f3 ff ff       	call   801027a8 <kalloc>
801034a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a6:	83 e8 04             	sub    $0x4,%eax
801034a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ac:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b7:	83 e8 08             	sub    $0x8,%eax
801034ba:	c7 00 01 34 10 80    	movl   $0x80103401,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034c0:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ce:	83 e8 0c             	sub    $0xc,%eax
801034d1:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034df:	0f b6 00             	movzbl (%eax),%eax
801034e2:	0f b6 c0             	movzbl %al,%eax
801034e5:	83 ec 08             	sub    $0x8,%esp
801034e8:	52                   	push   %edx
801034e9:	50                   	push   %eax
801034ea:	e8 50 f6 ff ff       	call   80102b3f <lapicstartap>
801034ef:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f2:	90                   	nop
801034f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fc:	85 c0                	test   %eax,%eax
801034fe:	74 f3                	je     801034f3 <startothers+0x91>
80103500:	eb 01                	jmp    80103503 <startothers+0xa1>
      continue;
80103502:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103503:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
8010350a:	a1 40 6c 19 80       	mov    0x80196c40,%eax
8010350f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103515:	05 80 69 19 80       	add    $0x80196980,%eax
8010351a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351d:	0f 82 6e ff ff ff    	jb     80103491 <startothers+0x2f>
      ;
  }
}
80103523:	90                   	nop
80103524:	90                   	nop
80103525:	c9                   	leave
80103526:	c3                   	ret

80103527 <outb>:
{
80103527:	55                   	push   %ebp
80103528:	89 e5                	mov    %esp,%ebp
8010352a:	83 ec 08             	sub    $0x8,%esp
8010352d:	8b 55 08             	mov    0x8(%ebp),%edx
80103530:	8b 45 0c             	mov    0xc(%ebp),%eax
80103533:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave
80103545:	c3                   	ret

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d2 ff ff ff       	call   80103527 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 c0 ff ff ff       	call   80103527 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave
8010356c:	c3                   	ret

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 55 da ff ff       	call   80100fe7 <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 3e da ff ff       	call   80100fe7 <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e8 f1 ff ff       	call   801027a8 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 c1 a3 10 80       	push   $0x8010a3c1
8010360c:	50                   	push   %eax
8010360d:	e8 d7 11 00 00       	call   801047e9 <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 8d f0 ff ff       	call   8010270e <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 0a da ff ff       	call   801010a5 <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 f0 d9 ff ff       	call   801010a5 <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave
801036be:	c3                   	ret

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 3a 11 00 00       	call   8010480b <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 c8 0c 00 00       	call   801043c0 <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 a5 0c 00 00       	call   801043c0 <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 35 11 00 00       	call   80104879 <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 bc ef ff ff       	call   8010270e <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 16 11 00 00       	call   80104879 <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave
80103769:	c3                   	ret

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 8e 10 00 00       	call   8010480b <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 c8 10 00 00       	call   80104879 <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 f1 0b 00 00       	call   801043c0 <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 f1 0a 00 00       	call   801042d9 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 6e 0b 00 00       	call   801043c0 <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 18 10 00 00       	call   80104879 <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave
8010386b:	c3                   	ret

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 8d 0f 00 00       	call   8010480b <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 de 0f 00 00       	call   80104879 <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 1b 0a 00 00       	call   801042d9 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 6f 0a 00 00       	call   801043c0 <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 19 0f 00 00       	call   80104879 <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave
80103967:	c3                   	ret

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave
80103977:	c3                   	ret

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 c8 a3 10 80       	push   $0x8010a3c8
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 52 0e 00 00       	call   801047e9 <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave
8010399c:	c3                   	ret

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 69 19 80       	sub    $0x80196980,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave
801039b7:	c3                   	ret

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 d0 a3 10 80       	push   $0x8010a3d0
801039d4:	e8 e8 cb ff ff       	call   801005c1 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1e f1 ff ff       	call   80102afc <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 69 19 80       	add    $0x80196980,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 69 19 80       	add    $0x80196980,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 f6 a3 10 80       	push   $0x8010a3f6
80103a29:	e8 93 cb ff ff       	call   801005c1 <panic>
}
80103a2e:	c9                   	leave
80103a2f:	c3                   	ret

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 3b 0f 00 00       	call   80104976 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 6f 0f 00 00       	call   801049c3 <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave
80103a58:	c3                   	ret

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 9f 0d 00 00       	call   8010480b <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 0e                	jmp    80103a86 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 27                	je     80103aa9 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103a86:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 42 19 80       	push   $0x80194200
80103a97:	e8 dd 0d 00 00       	call   80104879 <release>
80103a9c:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa4:	e9 b2 00 00 00       	jmp    80103b5b <allocproc+0x102>
      goto found;
80103aa9:	90                   	nop

found:
  p->state = EMBRYO;
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab4:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ab9:	8d 50 01             	lea    0x1(%eax),%edx
80103abc:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac5:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
80103ac8:	83 ec 0c             	sub    $0xc,%esp
80103acb:	68 00 42 19 80       	push   $0x80194200
80103ad0:	e8 a4 0d 00 00       	call   80104879 <release>
80103ad5:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ad8:	e8 cb ec ff ff       	call   801027a8 <kalloc>
80103add:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ae0:	89 42 08             	mov    %eax,0x8(%edx)
80103ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae6:	8b 40 08             	mov    0x8(%eax),%eax
80103ae9:	85 c0                	test   %eax,%eax
80103aeb:	75 11                	jne    80103afe <allocproc+0xa5>
    p->state = UNUSED;
80103aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af0:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103af7:	b8 00 00 00 00       	mov    $0x0,%eax
80103afc:	eb 5d                	jmp    80103b5b <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80103afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b01:	8b 40 08             	mov    0x8(%eax),%eax
80103b04:	05 00 10 00 00       	add    $0x1000,%eax
80103b09:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b0c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b13:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b16:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b19:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b1d:	ba 17 5e 10 80       	mov    $0x80105e17,%edx
80103b22:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b25:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b27:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b31:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b37:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b3a:	83 ec 04             	sub    $0x4,%esp
80103b3d:	6a 14                	push   $0x14
80103b3f:	6a 00                	push   $0x0
80103b41:	50                   	push   %eax
80103b42:	e8 3a 0f 00 00       	call   80104a81 <memset>
80103b47:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b50:	ba 93 42 10 80       	mov    $0x80104293,%edx
80103b55:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b5b:	c9                   	leave
80103b5c:	c3                   	ret

80103b5d <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b5d:	55                   	push   %ebp
80103b5e:	89 e5                	mov    %esp,%ebp
80103b60:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b63:	e8 f1 fe ff ff       	call   80103a59 <allocproc>
80103b68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6e:	a3 34 61 19 80       	mov    %eax,0x80196134
  if((p->pgdir = setupkvm()) == 0){
80103b73:	e8 8d 38 00 00       	call   80107405 <setupkvm>
80103b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b7b:	89 42 04             	mov    %eax,0x4(%edx)
80103b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b81:	8b 40 04             	mov    0x4(%eax),%eax
80103b84:	85 c0                	test   %eax,%eax
80103b86:	75 0d                	jne    80103b95 <userinit+0x38>
    panic("userinit: out of memory?");
80103b88:	83 ec 0c             	sub    $0xc,%esp
80103b8b:	68 06 a4 10 80       	push   $0x8010a406
80103b90:	e8 2c ca ff ff       	call   801005c1 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b95:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9d:	8b 40 04             	mov    0x4(%eax),%eax
80103ba0:	83 ec 04             	sub    $0x4,%esp
80103ba3:	52                   	push   %edx
80103ba4:	68 ec f4 10 80       	push   $0x8010f4ec
80103ba9:	50                   	push   %eax
80103baa:	e8 13 3b 00 00       	call   801076c2 <inituvm>
80103baf:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbe:	8b 40 18             	mov    0x18(%eax),%eax
80103bc1:	83 ec 04             	sub    $0x4,%esp
80103bc4:	6a 4c                	push   $0x4c
80103bc6:	6a 00                	push   $0x0
80103bc8:	50                   	push   %eax
80103bc9:	e8 b3 0e 00 00       	call   80104a81 <memset>
80103bce:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd4:	8b 40 18             	mov    0x18(%eax),%eax
80103bd7:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be0:	8b 40 18             	mov    0x18(%eax),%eax
80103be3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bec:	8b 50 18             	mov    0x18(%eax),%edx
80103bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf2:	8b 40 18             	mov    0x18(%eax),%eax
80103bf5:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103bf9:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c00:	8b 50 18             	mov    0x18(%eax),%edx
80103c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c06:	8b 40 18             	mov    0x18(%eax),%eax
80103c09:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c0d:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c14:	8b 40 18             	mov    0x18(%eax),%eax
80103c17:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c21:	8b 40 18             	mov    0x18(%eax),%eax
80103c24:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2e:	8b 40 18             	mov    0x18(%eax),%eax
80103c31:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3b:	83 c0 6c             	add    $0x6c,%eax
80103c3e:	83 ec 04             	sub    $0x4,%esp
80103c41:	6a 10                	push   $0x10
80103c43:	68 1f a4 10 80       	push   $0x8010a41f
80103c48:	50                   	push   %eax
80103c49:	e8 36 10 00 00       	call   80104c84 <safestrcpy>
80103c4e:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c51:	83 ec 0c             	sub    $0xc,%esp
80103c54:	68 28 a4 10 80       	push   $0x8010a428
80103c59:	e8 c7 e8 ff ff       	call   80102525 <namei>
80103c5e:	83 c4 10             	add    $0x10,%esp
80103c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c64:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c67:	83 ec 0c             	sub    $0xc,%esp
80103c6a:	68 00 42 19 80       	push   $0x80194200
80103c6f:	e8 97 0b 00 00       	call   8010480b <acquire>
80103c74:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c7a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	68 00 42 19 80       	push   $0x80194200
80103c89:	e8 eb 0b 00 00       	call   80104879 <release>
80103c8e:	83 c4 10             	add    $0x10,%esp
}
80103c91:	90                   	nop
80103c92:	c9                   	leave
80103c93:	c3                   	ret

80103c94 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c94:	55                   	push   %ebp
80103c95:	89 e5                	mov    %esp,%ebp
80103c97:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103c9a:	e8 91 fd ff ff       	call   80103a30 <myproc>
80103c9f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca5:	8b 00                	mov    (%eax),%eax
80103ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103caa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cae:	7e 2e                	jle    80103cde <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cb0:	8b 55 08             	mov    0x8(%ebp),%edx
80103cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cb6:	01 c2                	add    %eax,%edx
80103cb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbb:	8b 40 04             	mov    0x4(%eax),%eax
80103cbe:	83 ec 04             	sub    $0x4,%esp
80103cc1:	52                   	push   %edx
80103cc2:	ff 75 f4             	push   -0xc(%ebp)
80103cc5:	50                   	push   %eax
80103cc6:	e8 34 3b 00 00       	call   801077ff <allocuvm>
80103ccb:	83 c4 10             	add    $0x10,%esp
80103cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd5:	75 3b                	jne    80103d12 <growproc+0x7e>
      return -1;
80103cd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cdc:	eb 4f                	jmp    80103d2d <growproc+0x99>
  } else if(n < 0){
80103cde:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103ce2:	79 2e                	jns    80103d12 <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103ce4:	8b 55 08             	mov    0x8(%ebp),%edx
80103ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cea:	01 c2                	add    %eax,%edx
80103cec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cef:	8b 40 04             	mov    0x4(%eax),%eax
80103cf2:	83 ec 04             	sub    $0x4,%esp
80103cf5:	52                   	push   %edx
80103cf6:	ff 75 f4             	push   -0xc(%ebp)
80103cf9:	50                   	push   %eax
80103cfa:	e8 05 3c 00 00       	call   80107904 <deallocuvm>
80103cff:	83 c4 10             	add    $0x10,%esp
80103d02:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d09:	75 07                	jne    80103d12 <growproc+0x7e>
      return -1;
80103d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d10:	eb 1b                	jmp    80103d2d <growproc+0x99>
  }
  curproc->sz = sz;
80103d12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d15:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d18:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d1a:	83 ec 0c             	sub    $0xc,%esp
80103d1d:	ff 75 f0             	push   -0x10(%ebp)
80103d20:	e8 fe 37 00 00       	call   80107523 <switchuvm>
80103d25:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d2d:	c9                   	leave
80103d2e:	c3                   	ret

80103d2f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d2f:	55                   	push   %ebp
80103d30:	89 e5                	mov    %esp,%ebp
80103d32:	57                   	push   %edi
80103d33:	56                   	push   %esi
80103d34:	53                   	push   %ebx
80103d35:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d38:	e8 f3 fc ff ff       	call   80103a30 <myproc>
80103d3d:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d40:	e8 14 fd ff ff       	call   80103a59 <allocproc>
80103d45:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d48:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d4c:	75 0a                	jne    80103d58 <fork+0x29>
    return -1;
80103d4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d53:	e9 48 01 00 00       	jmp    80103ea0 <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d5b:	8b 10                	mov    (%eax),%edx
80103d5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d60:	8b 40 04             	mov    0x4(%eax),%eax
80103d63:	83 ec 08             	sub    $0x8,%esp
80103d66:	52                   	push   %edx
80103d67:	50                   	push   %eax
80103d68:	e8 35 3d 00 00       	call   80107aa2 <copyuvm>
80103d6d:	83 c4 10             	add    $0x10,%esp
80103d70:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d73:	89 42 04             	mov    %eax,0x4(%edx)
80103d76:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d79:	8b 40 04             	mov    0x4(%eax),%eax
80103d7c:	85 c0                	test   %eax,%eax
80103d7e:	75 30                	jne    80103db0 <fork+0x81>
    kfree(np->kstack);
80103d80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d83:	8b 40 08             	mov    0x8(%eax),%eax
80103d86:	83 ec 0c             	sub    $0xc,%esp
80103d89:	50                   	push   %eax
80103d8a:	e8 7f e9 ff ff       	call   8010270e <kfree>
80103d8f:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d92:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d95:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103d9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d9f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103da6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103dab:	e9 f0 00 00 00       	jmp    80103ea0 <fork+0x171>
  }
  np->sz = curproc->sz;
80103db0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103db3:	8b 10                	mov    (%eax),%edx
80103db5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103db8:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dba:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dbd:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dc0:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dc6:	8b 48 18             	mov    0x18(%eax),%ecx
80103dc9:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dcc:	8b 40 18             	mov    0x18(%eax),%eax
80103dcf:	89 c2                	mov    %eax,%edx
80103dd1:	89 cb                	mov    %ecx,%ebx
80103dd3:	b8 13 00 00 00       	mov    $0x13,%eax
80103dd8:	89 d7                	mov    %edx,%edi
80103dda:	89 de                	mov    %ebx,%esi
80103ddc:	89 c1                	mov    %eax,%ecx
80103dde:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103de3:	8b 40 18             	mov    0x18(%eax),%eax
80103de6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103ded:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103df4:	eb 3b                	jmp    80103e31 <fork+0x102>
    if(curproc->ofile[i])
80103df6:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103df9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103dfc:	83 c2 08             	add    $0x8,%edx
80103dff:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e03:	85 c0                	test   %eax,%eax
80103e05:	74 26                	je     80103e2d <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e07:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e0a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e0d:	83 c2 08             	add    $0x8,%edx
80103e10:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e14:	83 ec 0c             	sub    $0xc,%esp
80103e17:	50                   	push   %eax
80103e18:	e8 37 d2 ff ff       	call   80101054 <filedup>
80103e1d:	83 c4 10             	add    $0x10,%esp
80103e20:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e26:	83 c1 08             	add    $0x8,%ecx
80103e29:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e2d:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e31:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e35:	7e bf                	jle    80103df6 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e37:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e3a:	8b 40 68             	mov    0x68(%eax),%eax
80103e3d:	83 ec 0c             	sub    $0xc,%esp
80103e40:	50                   	push   %eax
80103e41:	e8 72 db ff ff       	call   801019b8 <idup>
80103e46:	83 c4 10             	add    $0x10,%esp
80103e49:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e4c:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e52:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e55:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e58:	83 c0 6c             	add    $0x6c,%eax
80103e5b:	83 ec 04             	sub    $0x4,%esp
80103e5e:	6a 10                	push   $0x10
80103e60:	52                   	push   %edx
80103e61:	50                   	push   %eax
80103e62:	e8 1d 0e 00 00       	call   80104c84 <safestrcpy>
80103e67:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e6d:	8b 40 10             	mov    0x10(%eax),%eax
80103e70:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e73:	83 ec 0c             	sub    $0xc,%esp
80103e76:	68 00 42 19 80       	push   $0x80194200
80103e7b:	e8 8b 09 00 00       	call   8010480b <acquire>
80103e80:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e83:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e86:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e8d:	83 ec 0c             	sub    $0xc,%esp
80103e90:	68 00 42 19 80       	push   $0x80194200
80103e95:	e8 df 09 00 00       	call   80104879 <release>
80103e9a:	83 c4 10             	add    $0x10,%esp

  return pid;
80103e9d:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ea3:	5b                   	pop    %ebx
80103ea4:	5e                   	pop    %esi
80103ea5:	5f                   	pop    %edi
80103ea6:	5d                   	pop    %ebp
80103ea7:	c3                   	ret

80103ea8 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103ea8:	55                   	push   %ebp
80103ea9:	89 e5                	mov    %esp,%ebp
80103eab:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eae:	e8 7d fb ff ff       	call   80103a30 <myproc>
80103eb3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103eb6:	a1 34 61 19 80       	mov    0x80196134,%eax
80103ebb:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ebe:	75 0d                	jne    80103ecd <exit+0x25>
    panic("init exiting");
80103ec0:	83 ec 0c             	sub    $0xc,%esp
80103ec3:	68 2a a4 10 80       	push   $0x8010a42a
80103ec8:	e8 f4 c6 ff ff       	call   801005c1 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ecd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ed4:	eb 3f                	jmp    80103f15 <exit+0x6d>
    if(curproc->ofile[fd]){
80103ed6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ed9:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103edc:	83 c2 08             	add    $0x8,%edx
80103edf:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ee3:	85 c0                	test   %eax,%eax
80103ee5:	74 2a                	je     80103f11 <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ee7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103eea:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103eed:	83 c2 08             	add    $0x8,%edx
80103ef0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103ef4:	83 ec 0c             	sub    $0xc,%esp
80103ef7:	50                   	push   %eax
80103ef8:	e8 a8 d1 ff ff       	call   801010a5 <fileclose>
80103efd:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f06:	83 c2 08             	add    $0x8,%edx
80103f09:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f10:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f11:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f15:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f19:	7e bb                	jle    80103ed6 <exit+0x2e>
    }
  }

  begin_op();
80103f1b:	e8 1e f1 ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
80103f20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f23:	8b 40 68             	mov    0x68(%eax),%eax
80103f26:	83 ec 0c             	sub    $0xc,%esp
80103f29:	50                   	push   %eax
80103f2a:	e8 24 dc ff ff       	call   80101b53 <iput>
80103f2f:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f32:	e8 93 f1 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80103f37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f3a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f41:	83 ec 0c             	sub    $0xc,%esp
80103f44:	68 00 42 19 80       	push   $0x80194200
80103f49:	e8 bd 08 00 00       	call   8010480b <acquire>
80103f4e:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f54:	8b 40 14             	mov    0x14(%eax),%eax
80103f57:	83 ec 0c             	sub    $0xc,%esp
80103f5a:	50                   	push   %eax
80103f5b:	e8 20 04 00 00       	call   80104380 <wakeup1>
80103f60:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f63:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f6a:	eb 37                	jmp    80103fa3 <exit+0xfb>
    if(p->parent == curproc){
80103f6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f6f:	8b 40 14             	mov    0x14(%eax),%eax
80103f72:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f75:	75 28                	jne    80103f9f <exit+0xf7>
      p->parent = initproc;
80103f77:	8b 15 34 61 19 80    	mov    0x80196134,%edx
80103f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f80:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f86:	8b 40 0c             	mov    0xc(%eax),%eax
80103f89:	83 f8 05             	cmp    $0x5,%eax
80103f8c:	75 11                	jne    80103f9f <exit+0xf7>
        wakeup1(initproc);
80103f8e:	a1 34 61 19 80       	mov    0x80196134,%eax
80103f93:	83 ec 0c             	sub    $0xc,%esp
80103f96:	50                   	push   %eax
80103f97:	e8 e4 03 00 00       	call   80104380 <wakeup1>
80103f9c:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80103fa3:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80103faa:	72 c0                	jb     80103f6c <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103faf:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fb6:	e8 e5 01 00 00       	call   801041a0 <sched>
  panic("zombie exit");
80103fbb:	83 ec 0c             	sub    $0xc,%esp
80103fbe:	68 37 a4 10 80       	push   $0x8010a437
80103fc3:	e8 f9 c5 ff ff       	call   801005c1 <panic>

80103fc8 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fce:	e8 5d fa ff ff       	call   80103a30 <myproc>
80103fd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fd6:	83 ec 0c             	sub    $0xc,%esp
80103fd9:	68 00 42 19 80       	push   $0x80194200
80103fde:	e8 28 08 00 00       	call   8010480b <acquire>
80103fe3:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103fe6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fed:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ff4:	e9 a1 00 00 00       	jmp    8010409a <wait+0xd2>
      if(p->parent != curproc)
80103ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ffc:	8b 40 14             	mov    0x14(%eax),%eax
80103fff:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104002:	0f 85 8d 00 00 00    	jne    80104095 <wait+0xcd>
        continue;
      havekids = 1;
80104008:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010400f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104012:	8b 40 0c             	mov    0xc(%eax),%eax
80104015:	83 f8 05             	cmp    $0x5,%eax
80104018:	75 7c                	jne    80104096 <wait+0xce>
        // Found one.
        pid = p->pid;
8010401a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401d:	8b 40 10             	mov    0x10(%eax),%eax
80104020:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104026:	8b 40 08             	mov    0x8(%eax),%eax
80104029:	83 ec 0c             	sub    $0xc,%esp
8010402c:	50                   	push   %eax
8010402d:	e8 dc e6 ff ff       	call   8010270e <kfree>
80104032:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104035:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104038:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010403f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104042:	8b 40 04             	mov    0x4(%eax),%eax
80104045:	83 ec 0c             	sub    $0xc,%esp
80104048:	50                   	push   %eax
80104049:	e8 7a 39 00 00       	call   801079c8 <freevm>
8010404e:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
80104051:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104054:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010406c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010406f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104079:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104080:	83 ec 0c             	sub    $0xc,%esp
80104083:	68 00 42 19 80       	push   $0x80194200
80104088:	e8 ec 07 00 00       	call   80104879 <release>
8010408d:	83 c4 10             	add    $0x10,%esp
        return pid;
80104090:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104093:	eb 51                	jmp    801040e6 <wait+0x11e>
        continue;
80104095:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104096:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010409a:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
801040a1:	0f 82 52 ff ff ff    	jb     80103ff9 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040a7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040ab:	74 0a                	je     801040b7 <wait+0xef>
801040ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040b0:	8b 40 24             	mov    0x24(%eax),%eax
801040b3:	85 c0                	test   %eax,%eax
801040b5:	74 17                	je     801040ce <wait+0x106>
      release(&ptable.lock);
801040b7:	83 ec 0c             	sub    $0xc,%esp
801040ba:	68 00 42 19 80       	push   $0x80194200
801040bf:	e8 b5 07 00 00       	call   80104879 <release>
801040c4:	83 c4 10             	add    $0x10,%esp
      return -1;
801040c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cc:	eb 18                	jmp    801040e6 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040ce:	83 ec 08             	sub    $0x8,%esp
801040d1:	68 00 42 19 80       	push   $0x80194200
801040d6:	ff 75 ec             	push   -0x14(%ebp)
801040d9:	e8 fb 01 00 00       	call   801042d9 <sleep>
801040de:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040e1:	e9 00 ff ff ff       	jmp    80103fe6 <wait+0x1e>
  }
}
801040e6:	c9                   	leave
801040e7:	c3                   	ret

801040e8 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040e8:	55                   	push   %ebp
801040e9:	89 e5                	mov    %esp,%ebp
801040eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040ee:	e8 c5 f8 ff ff       	call   801039b8 <mycpu>
801040f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801040f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801040f9:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104100:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104103:	e8 70 f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104108:	83 ec 0c             	sub    $0xc,%esp
8010410b:	68 00 42 19 80       	push   $0x80194200
80104110:	e8 f6 06 00 00       	call   8010480b <acquire>
80104115:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104118:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010411f:	eb 61                	jmp    80104182 <scheduler+0x9a>
      if(p->state != RUNNABLE)
80104121:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104124:	8b 40 0c             	mov    0xc(%eax),%eax
80104127:	83 f8 03             	cmp    $0x3,%eax
8010412a:	75 51                	jne    8010417d <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010412c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010412f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104132:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104138:	83 ec 0c             	sub    $0xc,%esp
8010413b:	ff 75 f4             	push   -0xc(%ebp)
8010413e:	e8 e0 33 00 00       	call   80107523 <switchuvm>
80104143:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104149:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104153:	8b 40 1c             	mov    0x1c(%eax),%eax
80104156:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104159:	83 c2 04             	add    $0x4,%edx
8010415c:	83 ec 08             	sub    $0x8,%esp
8010415f:	50                   	push   %eax
80104160:	52                   	push   %edx
80104161:	e8 90 0b 00 00       	call   80104cf6 <swtch>
80104166:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104169:	e8 9c 33 00 00       	call   8010750a <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010416e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104171:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104178:	00 00 00 
8010417b:	eb 01                	jmp    8010417e <scheduler+0x96>
        continue;
8010417d:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010417e:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104182:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104189:	72 96                	jb     80104121 <scheduler+0x39>
    }
    release(&ptable.lock);
8010418b:	83 ec 0c             	sub    $0xc,%esp
8010418e:	68 00 42 19 80       	push   $0x80194200
80104193:	e8 e1 06 00 00       	call   80104879 <release>
80104198:	83 c4 10             	add    $0x10,%esp
    sti();
8010419b:	e9 63 ff ff ff       	jmp    80104103 <scheduler+0x1b>

801041a0 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041a0:	55                   	push   %ebp
801041a1:	89 e5                	mov    %esp,%ebp
801041a3:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041a6:	e8 85 f8 ff ff       	call   80103a30 <myproc>
801041ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041ae:	83 ec 0c             	sub    $0xc,%esp
801041b1:	68 00 42 19 80       	push   $0x80194200
801041b6:	e8 8b 07 00 00       	call   80104946 <holding>
801041bb:	83 c4 10             	add    $0x10,%esp
801041be:	85 c0                	test   %eax,%eax
801041c0:	75 0d                	jne    801041cf <sched+0x2f>
    panic("sched ptable.lock");
801041c2:	83 ec 0c             	sub    $0xc,%esp
801041c5:	68 43 a4 10 80       	push   $0x8010a443
801041ca:	e8 f2 c3 ff ff       	call   801005c1 <panic>
  if(mycpu()->ncli != 1)
801041cf:	e8 e4 f7 ff ff       	call   801039b8 <mycpu>
801041d4:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041da:	83 f8 01             	cmp    $0x1,%eax
801041dd:	74 0d                	je     801041ec <sched+0x4c>
    panic("sched locks");
801041df:	83 ec 0c             	sub    $0xc,%esp
801041e2:	68 55 a4 10 80       	push   $0x8010a455
801041e7:	e8 d5 c3 ff ff       	call   801005c1 <panic>
  if(p->state == RUNNING)
801041ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ef:	8b 40 0c             	mov    0xc(%eax),%eax
801041f2:	83 f8 04             	cmp    $0x4,%eax
801041f5:	75 0d                	jne    80104204 <sched+0x64>
    panic("sched running");
801041f7:	83 ec 0c             	sub    $0xc,%esp
801041fa:	68 61 a4 10 80       	push   $0x8010a461
801041ff:	e8 bd c3 ff ff       	call   801005c1 <panic>
  if(readeflags()&FL_IF)
80104204:	e8 5f f7 ff ff       	call   80103968 <readeflags>
80104209:	25 00 02 00 00       	and    $0x200,%eax
8010420e:	85 c0                	test   %eax,%eax
80104210:	74 0d                	je     8010421f <sched+0x7f>
    panic("sched interruptible");
80104212:	83 ec 0c             	sub    $0xc,%esp
80104215:	68 6f a4 10 80       	push   $0x8010a46f
8010421a:	e8 a2 c3 ff ff       	call   801005c1 <panic>
  intena = mycpu()->intena;
8010421f:	e8 94 f7 ff ff       	call   801039b8 <mycpu>
80104224:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010422a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010422d:	e8 86 f7 ff ff       	call   801039b8 <mycpu>
80104232:	8b 40 04             	mov    0x4(%eax),%eax
80104235:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104238:	83 c2 1c             	add    $0x1c,%edx
8010423b:	83 ec 08             	sub    $0x8,%esp
8010423e:	50                   	push   %eax
8010423f:	52                   	push   %edx
80104240:	e8 b1 0a 00 00       	call   80104cf6 <swtch>
80104245:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104248:	e8 6b f7 ff ff       	call   801039b8 <mycpu>
8010424d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104250:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104256:	90                   	nop
80104257:	c9                   	leave
80104258:	c3                   	ret

80104259 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104259:	55                   	push   %ebp
8010425a:	89 e5                	mov    %esp,%ebp
8010425c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010425f:	83 ec 0c             	sub    $0xc,%esp
80104262:	68 00 42 19 80       	push   $0x80194200
80104267:	e8 9f 05 00 00       	call   8010480b <acquire>
8010426c:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
8010426f:	e8 bc f7 ff ff       	call   80103a30 <myproc>
80104274:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010427b:	e8 20 ff ff ff       	call   801041a0 <sched>
  release(&ptable.lock);
80104280:	83 ec 0c             	sub    $0xc,%esp
80104283:	68 00 42 19 80       	push   $0x80194200
80104288:	e8 ec 05 00 00       	call   80104879 <release>
8010428d:	83 c4 10             	add    $0x10,%esp
}
80104290:	90                   	nop
80104291:	c9                   	leave
80104292:	c3                   	ret

80104293 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104293:	55                   	push   %ebp
80104294:	89 e5                	mov    %esp,%ebp
80104296:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104299:	83 ec 0c             	sub    $0xc,%esp
8010429c:	68 00 42 19 80       	push   $0x80194200
801042a1:	e8 d3 05 00 00       	call   80104879 <release>
801042a6:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042a9:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042ae:	85 c0                	test   %eax,%eax
801042b0:	74 24                	je     801042d6 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042b2:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042b9:	00 00 00 
    iinit(ROOTDEV);
801042bc:	83 ec 0c             	sub    $0xc,%esp
801042bf:	6a 01                	push   $0x1
801042c1:	e8 bb d3 ff ff       	call   80101681 <iinit>
801042c6:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042c9:	83 ec 0c             	sub    $0xc,%esp
801042cc:	6a 01                	push   $0x1
801042ce:	e8 4c eb ff ff       	call   80102e1f <initlog>
801042d3:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042d6:	90                   	nop
801042d7:	c9                   	leave
801042d8:	c3                   	ret

801042d9 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042d9:	55                   	push   %ebp
801042da:	89 e5                	mov    %esp,%ebp
801042dc:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042df:	e8 4c f7 ff ff       	call   80103a30 <myproc>
801042e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042eb:	75 0d                	jne    801042fa <sleep+0x21>
    panic("sleep");
801042ed:	83 ec 0c             	sub    $0xc,%esp
801042f0:	68 83 a4 10 80       	push   $0x8010a483
801042f5:	e8 c7 c2 ff ff       	call   801005c1 <panic>

  if(lk == 0)
801042fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801042fe:	75 0d                	jne    8010430d <sleep+0x34>
    panic("sleep without lk");
80104300:	83 ec 0c             	sub    $0xc,%esp
80104303:	68 89 a4 10 80       	push   $0x8010a489
80104308:	e8 b4 c2 ff ff       	call   801005c1 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010430d:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104314:	74 1e                	je     80104334 <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104316:	83 ec 0c             	sub    $0xc,%esp
80104319:	68 00 42 19 80       	push   $0x80194200
8010431e:	e8 e8 04 00 00       	call   8010480b <acquire>
80104323:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104326:	83 ec 0c             	sub    $0xc,%esp
80104329:	ff 75 0c             	push   0xc(%ebp)
8010432c:	e8 48 05 00 00       	call   80104879 <release>
80104331:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
80104334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104337:	8b 55 08             	mov    0x8(%ebp),%edx
8010433a:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
8010433d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104340:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104347:	e8 54 fe ff ff       	call   801041a0 <sched>

  // Tidy up.
  p->chan = 0;
8010434c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434f:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104356:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010435d:	74 1e                	je     8010437d <sleep+0xa4>
    release(&ptable.lock);
8010435f:	83 ec 0c             	sub    $0xc,%esp
80104362:	68 00 42 19 80       	push   $0x80194200
80104367:	e8 0d 05 00 00       	call   80104879 <release>
8010436c:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
8010436f:	83 ec 0c             	sub    $0xc,%esp
80104372:	ff 75 0c             	push   0xc(%ebp)
80104375:	e8 91 04 00 00       	call   8010480b <acquire>
8010437a:	83 c4 10             	add    $0x10,%esp
  }
}
8010437d:	90                   	nop
8010437e:	c9                   	leave
8010437f:	c3                   	ret

80104380 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104380:	55                   	push   %ebp
80104381:	89 e5                	mov    %esp,%ebp
80104383:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104386:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
8010438d:	eb 24                	jmp    801043b3 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
8010438f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104392:	8b 40 0c             	mov    0xc(%eax),%eax
80104395:	83 f8 02             	cmp    $0x2,%eax
80104398:	75 15                	jne    801043af <wakeup1+0x2f>
8010439a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439d:	8b 40 20             	mov    0x20(%eax),%eax
801043a0:	39 45 08             	cmp    %eax,0x8(%ebp)
801043a3:	75 0a                	jne    801043af <wakeup1+0x2f>
      p->state = RUNNABLE;
801043a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043af:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
801043b3:	81 7d fc 34 61 19 80 	cmpl   $0x80196134,-0x4(%ebp)
801043ba:	72 d3                	jb     8010438f <wakeup1+0xf>
}
801043bc:	90                   	nop
801043bd:	90                   	nop
801043be:	c9                   	leave
801043bf:	c3                   	ret

801043c0 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043c0:	55                   	push   %ebp
801043c1:	89 e5                	mov    %esp,%ebp
801043c3:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043c6:	83 ec 0c             	sub    $0xc,%esp
801043c9:	68 00 42 19 80       	push   $0x80194200
801043ce:	e8 38 04 00 00       	call   8010480b <acquire>
801043d3:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043d6:	83 ec 0c             	sub    $0xc,%esp
801043d9:	ff 75 08             	push   0x8(%ebp)
801043dc:	e8 9f ff ff ff       	call   80104380 <wakeup1>
801043e1:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043e4:	83 ec 0c             	sub    $0xc,%esp
801043e7:	68 00 42 19 80       	push   $0x80194200
801043ec:	e8 88 04 00 00       	call   80104879 <release>
801043f1:	83 c4 10             	add    $0x10,%esp
}
801043f4:	90                   	nop
801043f5:	c9                   	leave
801043f6:	c3                   	ret

801043f7 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801043f7:	55                   	push   %ebp
801043f8:	89 e5                	mov    %esp,%ebp
801043fa:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
801043fd:	83 ec 0c             	sub    $0xc,%esp
80104400:	68 00 42 19 80       	push   $0x80194200
80104405:	e8 01 04 00 00       	call   8010480b <acquire>
8010440a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010440d:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104414:	eb 45                	jmp    8010445b <kill+0x64>
    if(p->pid == pid){
80104416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104419:	8b 40 10             	mov    0x10(%eax),%eax
8010441c:	39 45 08             	cmp    %eax,0x8(%ebp)
8010441f:	75 36                	jne    80104457 <kill+0x60>
      p->killed = 1;
80104421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104424:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010442b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442e:	8b 40 0c             	mov    0xc(%eax),%eax
80104431:	83 f8 02             	cmp    $0x2,%eax
80104434:	75 0a                	jne    80104440 <kill+0x49>
        p->state = RUNNABLE;
80104436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104439:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104440:	83 ec 0c             	sub    $0xc,%esp
80104443:	68 00 42 19 80       	push   $0x80194200
80104448:	e8 2c 04 00 00       	call   80104879 <release>
8010444d:	83 c4 10             	add    $0x10,%esp
      return 0;
80104450:	b8 00 00 00 00       	mov    $0x0,%eax
80104455:	eb 22                	jmp    80104479 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104457:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
8010445b:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
80104462:	72 b2                	jb     80104416 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104464:	83 ec 0c             	sub    $0xc,%esp
80104467:	68 00 42 19 80       	push   $0x80194200
8010446c:	e8 08 04 00 00       	call   80104879 <release>
80104471:	83 c4 10             	add    $0x10,%esp
  return -1;
80104474:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104479:	c9                   	leave
8010447a:	c3                   	ret

8010447b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010447b:	55                   	push   %ebp
8010447c:	89 e5                	mov    %esp,%ebp
8010447e:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104481:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104488:	e9 d7 00 00 00       	jmp    80104564 <procdump+0xe9>
    if(p->state == UNUSED)
8010448d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104490:	8b 40 0c             	mov    0xc(%eax),%eax
80104493:	85 c0                	test   %eax,%eax
80104495:	0f 84 c4 00 00 00    	je     8010455f <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010449b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449e:	8b 40 0c             	mov    0xc(%eax),%eax
801044a1:	83 f8 05             	cmp    $0x5,%eax
801044a4:	77 23                	ja     801044c9 <procdump+0x4e>
801044a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a9:	8b 40 0c             	mov    0xc(%eax),%eax
801044ac:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044b3:	85 c0                	test   %eax,%eax
801044b5:	74 12                	je     801044c9 <procdump+0x4e>
      state = states[p->state];
801044b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044ba:	8b 40 0c             	mov    0xc(%eax),%eax
801044bd:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044c7:	eb 07                	jmp    801044d0 <procdump+0x55>
    else
      state = "???";
801044c9:	c7 45 ec 9a a4 10 80 	movl   $0x8010a49a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d3:	8d 50 6c             	lea    0x6c(%eax),%edx
801044d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d9:	8b 40 10             	mov    0x10(%eax),%eax
801044dc:	52                   	push   %edx
801044dd:	ff 75 ec             	push   -0x14(%ebp)
801044e0:	50                   	push   %eax
801044e1:	68 9e a4 10 80       	push   $0x8010a49e
801044e6:	e8 09 bf ff ff       	call   801003f4 <cprintf>
801044eb:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044f1:	8b 40 0c             	mov    0xc(%eax),%eax
801044f4:	83 f8 02             	cmp    $0x2,%eax
801044f7:	75 54                	jne    8010454d <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801044f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044fc:	8b 40 1c             	mov    0x1c(%eax),%eax
801044ff:	8b 40 0c             	mov    0xc(%eax),%eax
80104502:	83 c0 08             	add    $0x8,%eax
80104505:	89 c2                	mov    %eax,%edx
80104507:	83 ec 08             	sub    $0x8,%esp
8010450a:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010450d:	50                   	push   %eax
8010450e:	52                   	push   %edx
8010450f:	e8 b7 03 00 00       	call   801048cb <getcallerpcs>
80104514:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104517:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010451e:	eb 1c                	jmp    8010453c <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104527:	83 ec 08             	sub    $0x8,%esp
8010452a:	50                   	push   %eax
8010452b:	68 a7 a4 10 80       	push   $0x8010a4a7
80104530:	e8 bf be ff ff       	call   801003f4 <cprintf>
80104535:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104538:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010453c:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104540:	7f 0b                	jg     8010454d <procdump+0xd2>
80104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104545:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104549:	85 c0                	test   %eax,%eax
8010454b:	75 d3                	jne    80104520 <procdump+0xa5>
    }
    cprintf("\n");
8010454d:	83 ec 0c             	sub    $0xc,%esp
80104550:	68 ab a4 10 80       	push   $0x8010a4ab
80104555:	e8 9a be ff ff       	call   801003f4 <cprintf>
8010455a:	83 c4 10             	add    $0x10,%esp
8010455d:	eb 01                	jmp    80104560 <procdump+0xe5>
      continue;
8010455f:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104560:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104564:	81 7d f0 34 61 19 80 	cmpl   $0x80196134,-0x10(%ebp)
8010456b:	0f 82 1c ff ff ff    	jb     8010448d <procdump+0x12>
  }
}
80104571:	90                   	nop
80104572:	90                   	nop
80104573:	c9                   	leave
80104574:	c3                   	ret

80104575 <printpt>:

int printpt(int pid) {
80104575:	55                   	push   %ebp
80104576:	89 e5                	mov    %esp,%ebp
80104578:	53                   	push   %ebx
80104579:	83 ec 14             	sub    $0x14,%esp
    pde_t *pgdir;
    pte_t *pte;
    uint a;

    // 프로세스 찾기
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
8010457c:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104583:	eb 0f                	jmp    80104594 <printpt+0x1f>
        if(p->pid == pid)
80104585:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104588:	8b 40 10             	mov    0x10(%eax),%eax
8010458b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010458e:	74 0f                	je     8010459f <printpt+0x2a>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80104590:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104594:	81 7d f4 34 61 19 80 	cmpl   $0x80196134,-0xc(%ebp)
8010459b:	72 e8                	jb     80104585 <printpt+0x10>
8010459d:	eb 01                	jmp    801045a0 <printpt+0x2b>
            break;
8010459f:	90                   	nop
    }
    if(p == 0 || p->pid != pid)
801045a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045a4:	74 0b                	je     801045b1 <printpt+0x3c>
801045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a9:	8b 40 10             	mov    0x10(%eax),%eax
801045ac:	39 45 08             	cmp    %eax,0x8(%ebp)
801045af:	74 0a                	je     801045bb <printpt+0x46>
        return -1;
801045b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b6:	e9 cc 00 00 00       	jmp    80104687 <printpt+0x112>

    pgdir = p->pgdir;
801045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045be:	8b 40 04             	mov    0x4(%eax),%eax
801045c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    cprintf("START PAGE TABLE (pid %d)\n", pid);
801045c4:	83 ec 08             	sub    $0x8,%esp
801045c7:	ff 75 08             	push   0x8(%ebp)
801045ca:	68 ad a4 10 80       	push   $0x8010a4ad
801045cf:	e8 20 be ff ff       	call   801003f4 <cprintf>
801045d4:	83 c4 10             	add    $0x10,%esp
    //a가 0부터 커널베이스까지 페이지 단위로 증가
    for(a = 0; a < KERNBASE; a += PGSIZE) {
801045d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045de:	e9 84 00 00 00       	jmp    80104667 <printpt+0xf2>
        pte = walkpgdir(pgdir, (void *)a, 0); //walkpgdir pgdir을 사용해 해당 pte를 찾아낸다.
801045e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045e6:	83 ec 04             	sub    $0x4,%esp
801045e9:	6a 00                	push   $0x0
801045eb:	50                   	push   %eax
801045ec:	ff 75 ec             	push   -0x14(%ebp)
801045ef:	e8 eb 2c 00 00       	call   801072df <walkpgdir>
801045f4:	83 c4 10             	add    $0x10,%esp
801045f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(pte && (*pte & PTE_P)) {
801045fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801045fe:	74 60                	je     80104660 <printpt+0xeb>
80104600:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104603:	8b 00                	mov    (%eax),%eax
80104605:	83 e0 01             	and    $0x1,%eax
80104608:	85 c0                	test   %eax,%eax
8010460a:	74 54                	je     80104660 <printpt+0xeb>
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
                (*pte & PTE_U) ? 'U' : 'K', //user모드인지 kernel인지
                (*pte & PTE_W) ? 'W' : '-', //읽기 or 쓰기
                PTE_ADDR(*pte)>>12); //프레임
8010460c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010460f:	8b 00                	mov    (%eax),%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
80104611:	c1 e8 0c             	shr    $0xc,%eax
80104614:	89 c2                	mov    %eax,%edx
                (*pte & PTE_W) ? 'W' : '-', //읽기 or 쓰기
80104616:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104619:	8b 00                	mov    (%eax),%eax
8010461b:	83 e0 02             	and    $0x2,%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
8010461e:	85 c0                	test   %eax,%eax
80104620:	74 07                	je     80104629 <printpt+0xb4>
80104622:	bb 57 00 00 00       	mov    $0x57,%ebx
80104627:	eb 05                	jmp    8010462e <printpt+0xb9>
80104629:	bb 2d 00 00 00       	mov    $0x2d,%ebx
                (*pte & PTE_U) ? 'U' : 'K', //user모드인지 kernel인지
8010462e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104631:	8b 00                	mov    (%eax),%eax
80104633:	83 e0 04             	and    $0x4,%eax
            cprintf("%x P %c %c %x\n", a >> 12, //가상 주소 페이지 번호 
80104636:	85 c0                	test   %eax,%eax
80104638:	74 07                	je     80104641 <printpt+0xcc>
8010463a:	b9 55 00 00 00       	mov    $0x55,%ecx
8010463f:	eb 05                	jmp    80104646 <printpt+0xd1>
80104641:	b9 4b 00 00 00       	mov    $0x4b,%ecx
80104646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104649:	c1 e8 0c             	shr    $0xc,%eax
8010464c:	83 ec 0c             	sub    $0xc,%esp
8010464f:	52                   	push   %edx
80104650:	53                   	push   %ebx
80104651:	51                   	push   %ecx
80104652:	50                   	push   %eax
80104653:	68 c8 a4 10 80       	push   $0x8010a4c8
80104658:	e8 97 bd ff ff       	call   801003f4 <cprintf>
8010465d:	83 c4 20             	add    $0x20,%esp
    for(a = 0; a < KERNBASE; a += PGSIZE) {
80104660:	81 45 f0 00 10 00 00 	addl   $0x1000,-0x10(%ebp)
80104667:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010466a:	85 c0                	test   %eax,%eax
8010466c:	0f 89 71 ff ff ff    	jns    801045e3 <printpt+0x6e>
        }
    }
    cprintf("END PAGE TABLE\n");
80104672:	83 ec 0c             	sub    $0xc,%esp
80104675:	68 d7 a4 10 80       	push   $0x8010a4d7
8010467a:	e8 75 bd ff ff       	call   801003f4 <cprintf>
8010467f:	83 c4 10             	add    $0x10,%esp
    return 0;
80104682:	b8 00 00 00 00       	mov    $0x0,%eax
80104687:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010468a:	c9                   	leave
8010468b:	c3                   	ret

8010468c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010468c:	55                   	push   %ebp
8010468d:	89 e5                	mov    %esp,%ebp
8010468f:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
80104692:	8b 45 08             	mov    0x8(%ebp),%eax
80104695:	83 c0 04             	add    $0x4,%eax
80104698:	83 ec 08             	sub    $0x8,%esp
8010469b:	68 11 a5 10 80       	push   $0x8010a511
801046a0:	50                   	push   %eax
801046a1:	e8 43 01 00 00       	call   801047e9 <initlock>
801046a6:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801046a9:	8b 45 08             	mov    0x8(%ebp),%eax
801046ac:	8b 55 0c             	mov    0xc(%ebp),%edx
801046af:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801046b2:	8b 45 08             	mov    0x8(%ebp),%eax
801046b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801046bb:	8b 45 08             	mov    0x8(%ebp),%eax
801046be:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801046c5:	90                   	nop
801046c6:	c9                   	leave
801046c7:	c3                   	ret

801046c8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801046c8:	55                   	push   %ebp
801046c9:	89 e5                	mov    %esp,%ebp
801046cb:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801046ce:	8b 45 08             	mov    0x8(%ebp),%eax
801046d1:	83 c0 04             	add    $0x4,%eax
801046d4:	83 ec 0c             	sub    $0xc,%esp
801046d7:	50                   	push   %eax
801046d8:	e8 2e 01 00 00       	call   8010480b <acquire>
801046dd:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801046e0:	eb 15                	jmp    801046f7 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801046e2:	8b 45 08             	mov    0x8(%ebp),%eax
801046e5:	83 c0 04             	add    $0x4,%eax
801046e8:	83 ec 08             	sub    $0x8,%esp
801046eb:	50                   	push   %eax
801046ec:	ff 75 08             	push   0x8(%ebp)
801046ef:	e8 e5 fb ff ff       	call   801042d9 <sleep>
801046f4:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801046f7:	8b 45 08             	mov    0x8(%ebp),%eax
801046fa:	8b 00                	mov    (%eax),%eax
801046fc:	85 c0                	test   %eax,%eax
801046fe:	75 e2                	jne    801046e2 <acquiresleep+0x1a>
  }
  lk->locked = 1;
80104700:	8b 45 08             	mov    0x8(%ebp),%eax
80104703:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104709:	e8 22 f3 ff ff       	call   80103a30 <myproc>
8010470e:	8b 50 10             	mov    0x10(%eax),%edx
80104711:	8b 45 08             	mov    0x8(%ebp),%eax
80104714:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104717:	8b 45 08             	mov    0x8(%ebp),%eax
8010471a:	83 c0 04             	add    $0x4,%eax
8010471d:	83 ec 0c             	sub    $0xc,%esp
80104720:	50                   	push   %eax
80104721:	e8 53 01 00 00       	call   80104879 <release>
80104726:	83 c4 10             	add    $0x10,%esp
}
80104729:	90                   	nop
8010472a:	c9                   	leave
8010472b:	c3                   	ret

8010472c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
8010472c:	55                   	push   %ebp
8010472d:	89 e5                	mov    %esp,%ebp
8010472f:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
80104732:	8b 45 08             	mov    0x8(%ebp),%eax
80104735:	83 c0 04             	add    $0x4,%eax
80104738:	83 ec 0c             	sub    $0xc,%esp
8010473b:	50                   	push   %eax
8010473c:	e8 ca 00 00 00       	call   8010480b <acquire>
80104741:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
80104744:	8b 45 08             	mov    0x8(%ebp),%eax
80104747:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010474d:	8b 45 08             	mov    0x8(%ebp),%eax
80104750:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104757:	83 ec 0c             	sub    $0xc,%esp
8010475a:	ff 75 08             	push   0x8(%ebp)
8010475d:	e8 5e fc ff ff       	call   801043c0 <wakeup>
80104762:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104765:	8b 45 08             	mov    0x8(%ebp),%eax
80104768:	83 c0 04             	add    $0x4,%eax
8010476b:	83 ec 0c             	sub    $0xc,%esp
8010476e:	50                   	push   %eax
8010476f:	e8 05 01 00 00       	call   80104879 <release>
80104774:	83 c4 10             	add    $0x10,%esp
}
80104777:	90                   	nop
80104778:	c9                   	leave
80104779:	c3                   	ret

8010477a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010477a:	55                   	push   %ebp
8010477b:	89 e5                	mov    %esp,%ebp
8010477d:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
80104780:	8b 45 08             	mov    0x8(%ebp),%eax
80104783:	83 c0 04             	add    $0x4,%eax
80104786:	83 ec 0c             	sub    $0xc,%esp
80104789:	50                   	push   %eax
8010478a:	e8 7c 00 00 00       	call   8010480b <acquire>
8010478f:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
80104792:	8b 45 08             	mov    0x8(%ebp),%eax
80104795:	8b 00                	mov    (%eax),%eax
80104797:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
8010479a:	8b 45 08             	mov    0x8(%ebp),%eax
8010479d:	83 c0 04             	add    $0x4,%eax
801047a0:	83 ec 0c             	sub    $0xc,%esp
801047a3:	50                   	push   %eax
801047a4:	e8 d0 00 00 00       	call   80104879 <release>
801047a9:	83 c4 10             	add    $0x10,%esp
  return r;
801047ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801047af:	c9                   	leave
801047b0:	c3                   	ret

801047b1 <readeflags>:
{
801047b1:	55                   	push   %ebp
801047b2:	89 e5                	mov    %esp,%ebp
801047b4:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801047b7:	9c                   	pushf
801047b8:	58                   	pop    %eax
801047b9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801047bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047bf:	c9                   	leave
801047c0:	c3                   	ret

801047c1 <cli>:
{
801047c1:	55                   	push   %ebp
801047c2:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801047c4:	fa                   	cli
}
801047c5:	90                   	nop
801047c6:	5d                   	pop    %ebp
801047c7:	c3                   	ret

801047c8 <sti>:
{
801047c8:	55                   	push   %ebp
801047c9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801047cb:	fb                   	sti
}
801047cc:	90                   	nop
801047cd:	5d                   	pop    %ebp
801047ce:	c3                   	ret

801047cf <xchg>:
{
801047cf:	55                   	push   %ebp
801047d0:	89 e5                	mov    %esp,%ebp
801047d2:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801047d5:	8b 55 08             	mov    0x8(%ebp),%edx
801047d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801047db:	8b 4d 08             	mov    0x8(%ebp),%ecx
801047de:	f0 87 02             	lock xchg %eax,(%edx)
801047e1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801047e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801047e7:	c9                   	leave
801047e8:	c3                   	ret

801047e9 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801047e9:	55                   	push   %ebp
801047ea:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801047ec:	8b 45 08             	mov    0x8(%ebp),%eax
801047ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801047f2:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801047f5:	8b 45 08             	mov    0x8(%ebp),%eax
801047f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801047fe:	8b 45 08             	mov    0x8(%ebp),%eax
80104801:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104808:	90                   	nop
80104809:	5d                   	pop    %ebp
8010480a:	c3                   	ret

8010480b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010480b:	55                   	push   %ebp
8010480c:	89 e5                	mov    %esp,%ebp
8010480e:	53                   	push   %ebx
8010480f:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104812:	e8 5f 01 00 00       	call   80104976 <pushcli>
  if(holding(lk)){
80104817:	8b 45 08             	mov    0x8(%ebp),%eax
8010481a:	83 ec 0c             	sub    $0xc,%esp
8010481d:	50                   	push   %eax
8010481e:	e8 23 01 00 00       	call   80104946 <holding>
80104823:	83 c4 10             	add    $0x10,%esp
80104826:	85 c0                	test   %eax,%eax
80104828:	74 0d                	je     80104837 <acquire+0x2c>
    panic("acquire");
8010482a:	83 ec 0c             	sub    $0xc,%esp
8010482d:	68 1c a5 10 80       	push   $0x8010a51c
80104832:	e8 8a bd ff ff       	call   801005c1 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104837:	90                   	nop
80104838:	8b 45 08             	mov    0x8(%ebp),%eax
8010483b:	83 ec 08             	sub    $0x8,%esp
8010483e:	6a 01                	push   $0x1
80104840:	50                   	push   %eax
80104841:	e8 89 ff ff ff       	call   801047cf <xchg>
80104846:	83 c4 10             	add    $0x10,%esp
80104849:	85 c0                	test   %eax,%eax
8010484b:	75 eb                	jne    80104838 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010484d:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80104852:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104855:	e8 5e f1 ff ff       	call   801039b8 <mycpu>
8010485a:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010485d:	8b 45 08             	mov    0x8(%ebp),%eax
80104860:	83 c0 0c             	add    $0xc,%eax
80104863:	83 ec 08             	sub    $0x8,%esp
80104866:	50                   	push   %eax
80104867:	8d 45 08             	lea    0x8(%ebp),%eax
8010486a:	50                   	push   %eax
8010486b:	e8 5b 00 00 00       	call   801048cb <getcallerpcs>
80104870:	83 c4 10             	add    $0x10,%esp
}
80104873:	90                   	nop
80104874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104877:	c9                   	leave
80104878:	c3                   	ret

80104879 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104879:	55                   	push   %ebp
8010487a:	89 e5                	mov    %esp,%ebp
8010487c:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010487f:	83 ec 0c             	sub    $0xc,%esp
80104882:	ff 75 08             	push   0x8(%ebp)
80104885:	e8 bc 00 00 00       	call   80104946 <holding>
8010488a:	83 c4 10             	add    $0x10,%esp
8010488d:	85 c0                	test   %eax,%eax
8010488f:	75 0d                	jne    8010489e <release+0x25>
    panic("release");
80104891:	83 ec 0c             	sub    $0xc,%esp
80104894:	68 24 a5 10 80       	push   $0x8010a524
80104899:	e8 23 bd ff ff       	call   801005c1 <panic>

  lk->pcs[0] = 0;
8010489e:	8b 45 08             	mov    0x8(%ebp),%eax
801048a1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801048a8:	8b 45 08             	mov    0x8(%ebp),%eax
801048ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801048b2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801048b7:	8b 45 08             	mov    0x8(%ebp),%eax
801048ba:	8b 55 08             	mov    0x8(%ebp),%edx
801048bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801048c3:	e8 fb 00 00 00       	call   801049c3 <popcli>
}
801048c8:	90                   	nop
801048c9:	c9                   	leave
801048ca:	c3                   	ret

801048cb <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801048cb:	55                   	push   %ebp
801048cc:	89 e5                	mov    %esp,%ebp
801048ce:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801048d1:	8b 45 08             	mov    0x8(%ebp),%eax
801048d4:	83 e8 08             	sub    $0x8,%eax
801048d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801048da:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801048e1:	eb 38                	jmp    8010491b <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801048e3:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801048e7:	74 53                	je     8010493c <getcallerpcs+0x71>
801048e9:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801048f0:	76 4a                	jbe    8010493c <getcallerpcs+0x71>
801048f2:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801048f6:	74 44                	je     8010493c <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
801048f8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801048fb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104902:	8b 45 0c             	mov    0xc(%ebp),%eax
80104905:	01 c2                	add    %eax,%edx
80104907:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010490a:	8b 40 04             	mov    0x4(%eax),%eax
8010490d:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010490f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104912:	8b 00                	mov    (%eax),%eax
80104914:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104917:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010491b:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010491f:	7e c2                	jle    801048e3 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80104921:	eb 19                	jmp    8010493c <getcallerpcs+0x71>
    pcs[i] = 0;
80104923:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104926:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010492d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104930:	01 d0                	add    %edx,%eax
80104932:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104938:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010493c:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80104940:	7e e1                	jle    80104923 <getcallerpcs+0x58>
}
80104942:	90                   	nop
80104943:	90                   	nop
80104944:	c9                   	leave
80104945:	c3                   	ret

80104946 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104946:	55                   	push   %ebp
80104947:	89 e5                	mov    %esp,%ebp
80104949:	53                   	push   %ebx
8010494a:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
8010494d:	8b 45 08             	mov    0x8(%ebp),%eax
80104950:	8b 00                	mov    (%eax),%eax
80104952:	85 c0                	test   %eax,%eax
80104954:	74 16                	je     8010496c <holding+0x26>
80104956:	8b 45 08             	mov    0x8(%ebp),%eax
80104959:	8b 58 08             	mov    0x8(%eax),%ebx
8010495c:	e8 57 f0 ff ff       	call   801039b8 <mycpu>
80104961:	39 c3                	cmp    %eax,%ebx
80104963:	75 07                	jne    8010496c <holding+0x26>
80104965:	b8 01 00 00 00       	mov    $0x1,%eax
8010496a:	eb 05                	jmp    80104971 <holding+0x2b>
8010496c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104971:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104974:	c9                   	leave
80104975:	c3                   	ret

80104976 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104976:	55                   	push   %ebp
80104977:	89 e5                	mov    %esp,%ebp
80104979:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
8010497c:	e8 30 fe ff ff       	call   801047b1 <readeflags>
80104981:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80104984:	e8 38 fe ff ff       	call   801047c1 <cli>
  if(mycpu()->ncli == 0)
80104989:	e8 2a f0 ff ff       	call   801039b8 <mycpu>
8010498e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104994:	85 c0                	test   %eax,%eax
80104996:	75 14                	jne    801049ac <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80104998:	e8 1b f0 ff ff       	call   801039b8 <mycpu>
8010499d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049a0:	81 e2 00 02 00 00    	and    $0x200,%edx
801049a6:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801049ac:	e8 07 f0 ff ff       	call   801039b8 <mycpu>
801049b1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801049b7:	83 c2 01             	add    $0x1,%edx
801049ba:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801049c0:	90                   	nop
801049c1:	c9                   	leave
801049c2:	c3                   	ret

801049c3 <popcli>:

void
popcli(void)
{
801049c3:	55                   	push   %ebp
801049c4:	89 e5                	mov    %esp,%ebp
801049c6:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801049c9:	e8 e3 fd ff ff       	call   801047b1 <readeflags>
801049ce:	25 00 02 00 00       	and    $0x200,%eax
801049d3:	85 c0                	test   %eax,%eax
801049d5:	74 0d                	je     801049e4 <popcli+0x21>
    panic("popcli - interruptible");
801049d7:	83 ec 0c             	sub    $0xc,%esp
801049da:	68 2c a5 10 80       	push   $0x8010a52c
801049df:	e8 dd bb ff ff       	call   801005c1 <panic>
  if(--mycpu()->ncli < 0)
801049e4:	e8 cf ef ff ff       	call   801039b8 <mycpu>
801049e9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801049ef:	83 ea 01             	sub    $0x1,%edx
801049f2:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801049f8:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049fe:	85 c0                	test   %eax,%eax
80104a00:	79 0d                	jns    80104a0f <popcli+0x4c>
    panic("popcli");
80104a02:	83 ec 0c             	sub    $0xc,%esp
80104a05:	68 43 a5 10 80       	push   $0x8010a543
80104a0a:	e8 b2 bb ff ff       	call   801005c1 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a0f:	e8 a4 ef ff ff       	call   801039b8 <mycpu>
80104a14:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a1a:	85 c0                	test   %eax,%eax
80104a1c:	75 14                	jne    80104a32 <popcli+0x6f>
80104a1e:	e8 95 ef ff ff       	call   801039b8 <mycpu>
80104a23:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104a29:	85 c0                	test   %eax,%eax
80104a2b:	74 05                	je     80104a32 <popcli+0x6f>
    sti();
80104a2d:	e8 96 fd ff ff       	call   801047c8 <sti>
}
80104a32:	90                   	nop
80104a33:	c9                   	leave
80104a34:	c3                   	ret

80104a35 <stosb>:
{
80104a35:	55                   	push   %ebp
80104a36:	89 e5                	mov    %esp,%ebp
80104a38:	57                   	push   %edi
80104a39:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104a3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a3d:	8b 55 10             	mov    0x10(%ebp),%edx
80104a40:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a43:	89 cb                	mov    %ecx,%ebx
80104a45:	89 df                	mov    %ebx,%edi
80104a47:	89 d1                	mov    %edx,%ecx
80104a49:	fc                   	cld
80104a4a:	f3 aa                	rep stos %al,%es:(%edi)
80104a4c:	89 ca                	mov    %ecx,%edx
80104a4e:	89 fb                	mov    %edi,%ebx
80104a50:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104a53:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104a56:	90                   	nop
80104a57:	5b                   	pop    %ebx
80104a58:	5f                   	pop    %edi
80104a59:	5d                   	pop    %ebp
80104a5a:	c3                   	ret

80104a5b <stosl>:
{
80104a5b:	55                   	push   %ebp
80104a5c:	89 e5                	mov    %esp,%ebp
80104a5e:	57                   	push   %edi
80104a5f:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80104a60:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104a63:	8b 55 10             	mov    0x10(%ebp),%edx
80104a66:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a69:	89 cb                	mov    %ecx,%ebx
80104a6b:	89 df                	mov    %ebx,%edi
80104a6d:	89 d1                	mov    %edx,%ecx
80104a6f:	fc                   	cld
80104a70:	f3 ab                	rep stos %eax,%es:(%edi)
80104a72:	89 ca                	mov    %ecx,%edx
80104a74:	89 fb                	mov    %edi,%ebx
80104a76:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104a79:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104a7c:	90                   	nop
80104a7d:	5b                   	pop    %ebx
80104a7e:	5f                   	pop    %edi
80104a7f:	5d                   	pop    %ebp
80104a80:	c3                   	ret

80104a81 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104a81:	55                   	push   %ebp
80104a82:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
80104a84:	8b 45 08             	mov    0x8(%ebp),%eax
80104a87:	83 e0 03             	and    $0x3,%eax
80104a8a:	85 c0                	test   %eax,%eax
80104a8c:	75 43                	jne    80104ad1 <memset+0x50>
80104a8e:	8b 45 10             	mov    0x10(%ebp),%eax
80104a91:	83 e0 03             	and    $0x3,%eax
80104a94:	85 c0                	test   %eax,%eax
80104a96:	75 39                	jne    80104ad1 <memset+0x50>
    c &= 0xFF;
80104a98:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104a9f:	8b 45 10             	mov    0x10(%ebp),%eax
80104aa2:	c1 e8 02             	shr    $0x2,%eax
80104aa5:	89 c1                	mov    %eax,%ecx
80104aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aaa:	c1 e0 18             	shl    $0x18,%eax
80104aad:	89 c2                	mov    %eax,%edx
80104aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ab2:	c1 e0 10             	shl    $0x10,%eax
80104ab5:	09 c2                	or     %eax,%edx
80104ab7:	8b 45 0c             	mov    0xc(%ebp),%eax
80104aba:	c1 e0 08             	shl    $0x8,%eax
80104abd:	09 d0                	or     %edx,%eax
80104abf:	0b 45 0c             	or     0xc(%ebp),%eax
80104ac2:	51                   	push   %ecx
80104ac3:	50                   	push   %eax
80104ac4:	ff 75 08             	push   0x8(%ebp)
80104ac7:	e8 8f ff ff ff       	call   80104a5b <stosl>
80104acc:	83 c4 0c             	add    $0xc,%esp
80104acf:	eb 12                	jmp    80104ae3 <memset+0x62>
  } else
    stosb(dst, c, n);
80104ad1:	8b 45 10             	mov    0x10(%ebp),%eax
80104ad4:	50                   	push   %eax
80104ad5:	ff 75 0c             	push   0xc(%ebp)
80104ad8:	ff 75 08             	push   0x8(%ebp)
80104adb:	e8 55 ff ff ff       	call   80104a35 <stosb>
80104ae0:	83 c4 0c             	add    $0xc,%esp
  return dst;
80104ae3:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ae6:	c9                   	leave
80104ae7:	c3                   	ret

80104ae8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104ae8:	55                   	push   %ebp
80104ae9:	89 e5                	mov    %esp,%ebp
80104aeb:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80104aee:	8b 45 08             	mov    0x8(%ebp),%eax
80104af1:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80104af4:	8b 45 0c             	mov    0xc(%ebp),%eax
80104af7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104afa:	eb 2e                	jmp    80104b2a <memcmp+0x42>
    if(*s1 != *s2)
80104afc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104aff:	0f b6 10             	movzbl (%eax),%edx
80104b02:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b05:	0f b6 00             	movzbl (%eax),%eax
80104b08:	38 c2                	cmp    %al,%dl
80104b0a:	74 16                	je     80104b22 <memcmp+0x3a>
      return *s1 - *s2;
80104b0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b0f:	0f b6 00             	movzbl (%eax),%eax
80104b12:	0f b6 d0             	movzbl %al,%edx
80104b15:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b18:	0f b6 00             	movzbl (%eax),%eax
80104b1b:	0f b6 c0             	movzbl %al,%eax
80104b1e:	29 c2                	sub    %eax,%edx
80104b20:	eb 1a                	jmp    80104b3c <memcmp+0x54>
    s1++, s2++;
80104b22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104b26:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104b2a:	8b 45 10             	mov    0x10(%ebp),%eax
80104b2d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b30:	89 55 10             	mov    %edx,0x10(%ebp)
80104b33:	85 c0                	test   %eax,%eax
80104b35:	75 c5                	jne    80104afc <memcmp+0x14>
  }

  return 0;
80104b37:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104b3c:	89 d0                	mov    %edx,%eax
80104b3e:	c9                   	leave
80104b3f:	c3                   	ret

80104b40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104b40:	55                   	push   %ebp
80104b41:	89 e5                	mov    %esp,%ebp
80104b43:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104b46:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b49:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104b4c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b4f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104b52:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b55:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104b58:	73 54                	jae    80104bae <memmove+0x6e>
80104b5a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104b5d:	8b 45 10             	mov    0x10(%ebp),%eax
80104b60:	01 d0                	add    %edx,%eax
80104b62:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104b65:	73 47                	jae    80104bae <memmove+0x6e>
    s += n;
80104b67:	8b 45 10             	mov    0x10(%ebp),%eax
80104b6a:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104b6d:	8b 45 10             	mov    0x10(%ebp),%eax
80104b70:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104b73:	eb 13                	jmp    80104b88 <memmove+0x48>
      *--d = *--s;
80104b75:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104b79:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104b7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b80:	0f b6 10             	movzbl (%eax),%edx
80104b83:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104b86:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104b88:	8b 45 10             	mov    0x10(%ebp),%eax
80104b8b:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b8e:	89 55 10             	mov    %edx,0x10(%ebp)
80104b91:	85 c0                	test   %eax,%eax
80104b93:	75 e0                	jne    80104b75 <memmove+0x35>
  if(s < d && s + n > d){
80104b95:	eb 24                	jmp    80104bbb <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104b97:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104b9a:	8d 42 01             	lea    0x1(%edx),%eax
80104b9d:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104ba0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104ba3:	8d 48 01             	lea    0x1(%eax),%ecx
80104ba6:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ba9:	0f b6 12             	movzbl (%edx),%edx
80104bac:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104bae:	8b 45 10             	mov    0x10(%ebp),%eax
80104bb1:	8d 50 ff             	lea    -0x1(%eax),%edx
80104bb4:	89 55 10             	mov    %edx,0x10(%ebp)
80104bb7:	85 c0                	test   %eax,%eax
80104bb9:	75 dc                	jne    80104b97 <memmove+0x57>

  return dst;
80104bbb:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104bbe:	c9                   	leave
80104bbf:	c3                   	ret

80104bc0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104bc0:	55                   	push   %ebp
80104bc1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104bc3:	ff 75 10             	push   0x10(%ebp)
80104bc6:	ff 75 0c             	push   0xc(%ebp)
80104bc9:	ff 75 08             	push   0x8(%ebp)
80104bcc:	e8 6f ff ff ff       	call   80104b40 <memmove>
80104bd1:	83 c4 0c             	add    $0xc,%esp
}
80104bd4:	c9                   	leave
80104bd5:	c3                   	ret

80104bd6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104bd6:	55                   	push   %ebp
80104bd7:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104bd9:	eb 0c                	jmp    80104be7 <strncmp+0x11>
    n--, p++, q++;
80104bdb:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104bdf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104be3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104be7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104beb:	74 1a                	je     80104c07 <strncmp+0x31>
80104bed:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf0:	0f b6 00             	movzbl (%eax),%eax
80104bf3:	84 c0                	test   %al,%al
80104bf5:	74 10                	je     80104c07 <strncmp+0x31>
80104bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80104bfa:	0f b6 10             	movzbl (%eax),%edx
80104bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c00:	0f b6 00             	movzbl (%eax),%eax
80104c03:	38 c2                	cmp    %al,%dl
80104c05:	74 d4                	je     80104bdb <strncmp+0x5>
  if(n == 0)
80104c07:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c0b:	75 07                	jne    80104c14 <strncmp+0x3e>
    return 0;
80104c0d:	ba 00 00 00 00       	mov    $0x0,%edx
80104c12:	eb 14                	jmp    80104c28 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80104c14:	8b 45 08             	mov    0x8(%ebp),%eax
80104c17:	0f b6 00             	movzbl (%eax),%eax
80104c1a:	0f b6 d0             	movzbl %al,%edx
80104c1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c20:	0f b6 00             	movzbl (%eax),%eax
80104c23:	0f b6 c0             	movzbl %al,%eax
80104c26:	29 c2                	sub    %eax,%edx
}
80104c28:	89 d0                	mov    %edx,%eax
80104c2a:	5d                   	pop    %ebp
80104c2b:	c3                   	ret

80104c2c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104c2c:	55                   	push   %ebp
80104c2d:	89 e5                	mov    %esp,%ebp
80104c2f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c32:	8b 45 08             	mov    0x8(%ebp),%eax
80104c35:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104c38:	90                   	nop
80104c39:	8b 45 10             	mov    0x10(%ebp),%eax
80104c3c:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c3f:	89 55 10             	mov    %edx,0x10(%ebp)
80104c42:	85 c0                	test   %eax,%eax
80104c44:	7e 2c                	jle    80104c72 <strncpy+0x46>
80104c46:	8b 55 0c             	mov    0xc(%ebp),%edx
80104c49:	8d 42 01             	lea    0x1(%edx),%eax
80104c4c:	89 45 0c             	mov    %eax,0xc(%ebp)
80104c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80104c52:	8d 48 01             	lea    0x1(%eax),%ecx
80104c55:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104c58:	0f b6 12             	movzbl (%edx),%edx
80104c5b:	88 10                	mov    %dl,(%eax)
80104c5d:	0f b6 00             	movzbl (%eax),%eax
80104c60:	84 c0                	test   %al,%al
80104c62:	75 d5                	jne    80104c39 <strncpy+0xd>
    ;
  while(n-- > 0)
80104c64:	eb 0c                	jmp    80104c72 <strncpy+0x46>
    *s++ = 0;
80104c66:	8b 45 08             	mov    0x8(%ebp),%eax
80104c69:	8d 50 01             	lea    0x1(%eax),%edx
80104c6c:	89 55 08             	mov    %edx,0x8(%ebp)
80104c6f:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104c72:	8b 45 10             	mov    0x10(%ebp),%eax
80104c75:	8d 50 ff             	lea    -0x1(%eax),%edx
80104c78:	89 55 10             	mov    %edx,0x10(%ebp)
80104c7b:	85 c0                	test   %eax,%eax
80104c7d:	7f e7                	jg     80104c66 <strncpy+0x3a>
  return os;
80104c7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104c82:	c9                   	leave
80104c83:	c3                   	ret

80104c84 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104c84:	55                   	push   %ebp
80104c85:	89 e5                	mov    %esp,%ebp
80104c87:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104c8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104c90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104c94:	7f 05                	jg     80104c9b <safestrcpy+0x17>
    return os;
80104c96:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104c99:	eb 32                	jmp    80104ccd <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104c9b:	90                   	nop
80104c9c:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104ca0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104ca4:	7e 1e                	jle    80104cc4 <safestrcpy+0x40>
80104ca6:	8b 55 0c             	mov    0xc(%ebp),%edx
80104ca9:	8d 42 01             	lea    0x1(%edx),%eax
80104cac:	89 45 0c             	mov    %eax,0xc(%ebp)
80104caf:	8b 45 08             	mov    0x8(%ebp),%eax
80104cb2:	8d 48 01             	lea    0x1(%eax),%ecx
80104cb5:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104cb8:	0f b6 12             	movzbl (%edx),%edx
80104cbb:	88 10                	mov    %dl,(%eax)
80104cbd:	0f b6 00             	movzbl (%eax),%eax
80104cc0:	84 c0                	test   %al,%al
80104cc2:	75 d8                	jne    80104c9c <safestrcpy+0x18>
    ;
  *s = 0;
80104cc4:	8b 45 08             	mov    0x8(%ebp),%eax
80104cc7:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104cca:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ccd:	c9                   	leave
80104cce:	c3                   	ret

80104ccf <strlen>:

int
strlen(const char *s)
{
80104ccf:	55                   	push   %ebp
80104cd0:	89 e5                	mov    %esp,%ebp
80104cd2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104cd5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104cdc:	eb 04                	jmp    80104ce2 <strlen+0x13>
80104cde:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104ce2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80104ce8:	01 d0                	add    %edx,%eax
80104cea:	0f b6 00             	movzbl (%eax),%eax
80104ced:	84 c0                	test   %al,%al
80104cef:	75 ed                	jne    80104cde <strlen+0xf>
    ;
  return n;
80104cf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cf4:	c9                   	leave
80104cf5:	c3                   	ret

80104cf6 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104cf6:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104cfa:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104cfe:	55                   	push   %ebp
  pushl %ebx
80104cff:	53                   	push   %ebx
  pushl %esi
80104d00:	56                   	push   %esi
  pushl %edi
80104d01:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104d02:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104d04:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104d06:	5f                   	pop    %edi
  popl %esi
80104d07:	5e                   	pop    %esi
  popl %ebx
80104d08:	5b                   	pop    %ebx
  popl %ebp
80104d09:	5d                   	pop    %ebp
  ret
80104d0a:	c3                   	ret

80104d0b <fetchint>:
  return 0;
}*/
//수정
int
fetchint(uint addr, int *ip)
{
80104d0b:	55                   	push   %ebp
80104d0c:	89 e5                	mov    %esp,%ebp
  //struct proc *curproc = myproc();

  if(addr >= KERNBASE || addr+4 > KERNBASE)
80104d0e:	8b 45 08             	mov    0x8(%ebp),%eax
80104d11:	85 c0                	test   %eax,%eax
80104d13:	78 0d                	js     80104d22 <fetchint+0x17>
80104d15:	8b 45 08             	mov    0x8(%ebp),%eax
80104d18:	83 c0 04             	add    $0x4,%eax
80104d1b:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104d20:	76 07                	jbe    80104d29 <fetchint+0x1e>
    return -1;
80104d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d27:	eb 0f                	jmp    80104d38 <fetchint+0x2d>
  *ip = *(int*)(addr);
80104d29:	8b 45 08             	mov    0x8(%ebp),%eax
80104d2c:	8b 10                	mov    (%eax),%edx
80104d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d31:	89 10                	mov    %edx,(%eax)
  return 0;
80104d33:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d38:	5d                   	pop    %ebp
80104d39:	c3                   	ret

80104d3a <fetchstr>:
  return -1;
}*/
//수정
int
fetchstr(uint addr, char **pp)
{
80104d3a:	55                   	push   %ebp
80104d3b:	89 e5                	mov    %esp,%ebp
80104d3d:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;
  //struct proc *curproc = myproc();

  if(addr >= KERNBASE)
80104d40:	8b 45 08             	mov    0x8(%ebp),%eax
80104d43:	85 c0                	test   %eax,%eax
80104d45:	79 07                	jns    80104d4e <fetchstr+0x14>
    return -1;
80104d47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d4c:	eb 40                	jmp    80104d8e <fetchstr+0x54>
  *pp = (char*)addr;
80104d4e:	8b 55 08             	mov    0x8(%ebp),%edx
80104d51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d54:	89 10                	mov    %edx,(%eax)
  ep = (char*)KERNBASE;
80104d56:	c7 45 f8 00 00 00 80 	movl   $0x80000000,-0x8(%ebp)
  for(s = *pp; s < ep; s++){
80104d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d60:	8b 00                	mov    (%eax),%eax
80104d62:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104d65:	eb 1a                	jmp    80104d81 <fetchstr+0x47>
    if(*s == 0)
80104d67:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d6a:	0f b6 00             	movzbl (%eax),%eax
80104d6d:	84 c0                	test   %al,%al
80104d6f:	75 0c                	jne    80104d7d <fetchstr+0x43>
      return s - *pp;
80104d71:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d74:	8b 10                	mov    (%eax),%edx
80104d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d79:	29 d0                	sub    %edx,%eax
80104d7b:	eb 11                	jmp    80104d8e <fetchstr+0x54>
  for(s = *pp; s < ep; s++){
80104d7d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104d81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104d84:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104d87:	72 de                	jb     80104d67 <fetchstr+0x2d>
  }
  return -1;
80104d89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d8e:	c9                   	leave
80104d8f:	c3                   	ret

80104d90 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104d90:	55                   	push   %ebp
80104d91:	89 e5                	mov    %esp,%ebp
80104d93:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104d96:	e8 95 ec ff ff       	call   80103a30 <myproc>
80104d9b:	8b 40 18             	mov    0x18(%eax),%eax
80104d9e:	8b 40 44             	mov    0x44(%eax),%eax
80104da1:	8b 55 08             	mov    0x8(%ebp),%edx
80104da4:	c1 e2 02             	shl    $0x2,%edx
80104da7:	01 d0                	add    %edx,%eax
80104da9:	83 c0 04             	add    $0x4,%eax
80104dac:	83 ec 08             	sub    $0x8,%esp
80104daf:	ff 75 0c             	push   0xc(%ebp)
80104db2:	50                   	push   %eax
80104db3:	e8 53 ff ff ff       	call   80104d0b <fetchint>
80104db8:	83 c4 10             	add    $0x10,%esp
}
80104dbb:	c9                   	leave
80104dbc:	c3                   	ret

80104dbd <argptr>:
  return 0;
}*/
//수정
int
argptr(int n, char **pp, int size)
{
80104dbd:	55                   	push   %ebp
80104dbe:	89 e5                	mov    %esp,%ebp
80104dc0:	83 ec 18             	sub    $0x18,%esp
  int i;
  //struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
80104dc3:	83 ec 08             	sub    $0x8,%esp
80104dc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104dc9:	50                   	push   %eax
80104dca:	ff 75 08             	push   0x8(%ebp)
80104dcd:	e8 be ff ff ff       	call   80104d90 <argint>
80104dd2:	83 c4 10             	add    $0x10,%esp
80104dd5:	85 c0                	test   %eax,%eax
80104dd7:	79 07                	jns    80104de0 <argptr+0x23>
    return -1;
80104dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dde:	eb 34                	jmp    80104e14 <argptr+0x57>
  if(size < 0 || (uint)i >= KERNBASE || (uint)i+size > KERNBASE)
80104de0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104de4:	78 18                	js     80104dfe <argptr+0x41>
80104de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de9:	85 c0                	test   %eax,%eax
80104deb:	78 11                	js     80104dfe <argptr+0x41>
80104ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df0:	89 c2                	mov    %eax,%edx
80104df2:	8b 45 10             	mov    0x10(%ebp),%eax
80104df5:	01 d0                	add    %edx,%eax
80104df7:	3d 00 00 00 80       	cmp    $0x80000000,%eax
80104dfc:	76 07                	jbe    80104e05 <argptr+0x48>
    return -1;
80104dfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e03:	eb 0f                	jmp    80104e14 <argptr+0x57>
  *pp = (char*)i;
80104e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e08:	89 c2                	mov    %eax,%edx
80104e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e0d:	89 10                	mov    %edx,(%eax)
  return 0;
80104e0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e14:	c9                   	leave
80104e15:	c3                   	ret

80104e16 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104e16:	55                   	push   %ebp
80104e17:	89 e5                	mov    %esp,%ebp
80104e19:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104e1c:	83 ec 08             	sub    $0x8,%esp
80104e1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e22:	50                   	push   %eax
80104e23:	ff 75 08             	push   0x8(%ebp)
80104e26:	e8 65 ff ff ff       	call   80104d90 <argint>
80104e2b:	83 c4 10             	add    $0x10,%esp
80104e2e:	85 c0                	test   %eax,%eax
80104e30:	79 07                	jns    80104e39 <argstr+0x23>
    return -1;
80104e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e37:	eb 12                	jmp    80104e4b <argstr+0x35>
  return fetchstr(addr, pp);
80104e39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e3c:	83 ec 08             	sub    $0x8,%esp
80104e3f:	ff 75 0c             	push   0xc(%ebp)
80104e42:	50                   	push   %eax
80104e43:	e8 f2 fe ff ff       	call   80104d3a <fetchstr>
80104e48:	83 c4 10             	add    $0x10,%esp
}
80104e4b:	c9                   	leave
80104e4c:	c3                   	ret

80104e4d <syscall>:
[SYS_printpt] sys_printpt,
};

void
syscall(void)
{
80104e4d:	55                   	push   %ebp
80104e4e:	89 e5                	mov    %esp,%ebp
80104e50:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104e53:	e8 d8 eb ff ff       	call   80103a30 <myproc>
80104e58:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5e:	8b 40 18             	mov    0x18(%eax),%eax
80104e61:	8b 40 1c             	mov    0x1c(%eax),%eax
80104e64:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104e67:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104e6b:	7e 2f                	jle    80104e9c <syscall+0x4f>
80104e6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e70:	83 f8 16             	cmp    $0x16,%eax
80104e73:	77 27                	ja     80104e9c <syscall+0x4f>
80104e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e78:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104e7f:	85 c0                	test   %eax,%eax
80104e81:	74 19                	je     80104e9c <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104e83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e86:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104e8d:	ff d0                	call   *%eax
80104e8f:	89 c2                	mov    %eax,%edx
80104e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e94:	8b 40 18             	mov    0x18(%eax),%eax
80104e97:	89 50 1c             	mov    %edx,0x1c(%eax)
80104e9a:	eb 2c                	jmp    80104ec8 <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104e9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9f:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea5:	8b 40 10             	mov    0x10(%eax),%eax
80104ea8:	ff 75 f0             	push   -0x10(%ebp)
80104eab:	52                   	push   %edx
80104eac:	50                   	push   %eax
80104ead:	68 4a a5 10 80       	push   $0x8010a54a
80104eb2:	e8 3d b5 ff ff       	call   801003f4 <cprintf>
80104eb7:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ebd:	8b 40 18             	mov    0x18(%eax),%eax
80104ec0:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104ec7:	90                   	nop
80104ec8:	90                   	nop
80104ec9:	c9                   	leave
80104eca:	c3                   	ret

80104ecb <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104ecb:	55                   	push   %ebp
80104ecc:	89 e5                	mov    %esp,%ebp
80104ece:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104ed1:	83 ec 08             	sub    $0x8,%esp
80104ed4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ed7:	50                   	push   %eax
80104ed8:	ff 75 08             	push   0x8(%ebp)
80104edb:	e8 b0 fe ff ff       	call   80104d90 <argint>
80104ee0:	83 c4 10             	add    $0x10,%esp
80104ee3:	85 c0                	test   %eax,%eax
80104ee5:	79 07                	jns    80104eee <argfd+0x23>
    return -1;
80104ee7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eec:	eb 4f                	jmp    80104f3d <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104eee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef1:	85 c0                	test   %eax,%eax
80104ef3:	78 20                	js     80104f15 <argfd+0x4a>
80104ef5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ef8:	83 f8 0f             	cmp    $0xf,%eax
80104efb:	7f 18                	jg     80104f15 <argfd+0x4a>
80104efd:	e8 2e eb ff ff       	call   80103a30 <myproc>
80104f02:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f05:	83 c2 08             	add    $0x8,%edx
80104f08:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104f0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f13:	75 07                	jne    80104f1c <argfd+0x51>
    return -1;
80104f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f1a:	eb 21                	jmp    80104f3d <argfd+0x72>
  if(pfd)
80104f1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f20:	74 08                	je     80104f2a <argfd+0x5f>
    *pfd = fd;
80104f22:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f25:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f28:	89 10                	mov    %edx,(%eax)
  if(pf)
80104f2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104f2e:	74 08                	je     80104f38 <argfd+0x6d>
    *pf = f;
80104f30:	8b 45 10             	mov    0x10(%ebp),%eax
80104f33:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f36:	89 10                	mov    %edx,(%eax)
  return 0;
80104f38:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f3d:	c9                   	leave
80104f3e:	c3                   	ret

80104f3f <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104f3f:	55                   	push   %ebp
80104f40:	89 e5                	mov    %esp,%ebp
80104f42:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104f45:	e8 e6 ea ff ff       	call   80103a30 <myproc>
80104f4a:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104f4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f54:	eb 2a                	jmp    80104f80 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f59:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f5c:	83 c2 08             	add    $0x8,%edx
80104f5f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104f63:	85 c0                	test   %eax,%eax
80104f65:	75 15                	jne    80104f7c <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f6d:	8d 4a 08             	lea    0x8(%edx),%ecx
80104f70:	8b 55 08             	mov    0x8(%ebp),%edx
80104f73:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f7a:	eb 0f                	jmp    80104f8b <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104f7c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104f80:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104f84:	7e d0                	jle    80104f56 <fdalloc+0x17>
    }
  }
  return -1;
80104f86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f8b:	c9                   	leave
80104f8c:	c3                   	ret

80104f8d <sys_dup>:

int
sys_dup(void)
{
80104f8d:	55                   	push   %ebp
80104f8e:	89 e5                	mov    %esp,%ebp
80104f90:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104f93:	83 ec 04             	sub    $0x4,%esp
80104f96:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f99:	50                   	push   %eax
80104f9a:	6a 00                	push   $0x0
80104f9c:	6a 00                	push   $0x0
80104f9e:	e8 28 ff ff ff       	call   80104ecb <argfd>
80104fa3:	83 c4 10             	add    $0x10,%esp
80104fa6:	85 c0                	test   %eax,%eax
80104fa8:	79 07                	jns    80104fb1 <sys_dup+0x24>
    return -1;
80104faa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104faf:	eb 31                	jmp    80104fe2 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104fb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb4:	83 ec 0c             	sub    $0xc,%esp
80104fb7:	50                   	push   %eax
80104fb8:	e8 82 ff ff ff       	call   80104f3f <fdalloc>
80104fbd:	83 c4 10             	add    $0x10,%esp
80104fc0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104fc3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104fc7:	79 07                	jns    80104fd0 <sys_dup+0x43>
    return -1;
80104fc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fce:	eb 12                	jmp    80104fe2 <sys_dup+0x55>
  filedup(f);
80104fd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd3:	83 ec 0c             	sub    $0xc,%esp
80104fd6:	50                   	push   %eax
80104fd7:	e8 78 c0 ff ff       	call   80101054 <filedup>
80104fdc:	83 c4 10             	add    $0x10,%esp
  return fd;
80104fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104fe2:	c9                   	leave
80104fe3:	c3                   	ret

80104fe4 <sys_read>:

int
sys_read(void)
{
80104fe4:	55                   	push   %ebp
80104fe5:	89 e5                	mov    %esp,%ebp
80104fe7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104fea:	83 ec 04             	sub    $0x4,%esp
80104fed:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ff0:	50                   	push   %eax
80104ff1:	6a 00                	push   $0x0
80104ff3:	6a 00                	push   $0x0
80104ff5:	e8 d1 fe ff ff       	call   80104ecb <argfd>
80104ffa:	83 c4 10             	add    $0x10,%esp
80104ffd:	85 c0                	test   %eax,%eax
80104fff:	78 2e                	js     8010502f <sys_read+0x4b>
80105001:	83 ec 08             	sub    $0x8,%esp
80105004:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105007:	50                   	push   %eax
80105008:	6a 02                	push   $0x2
8010500a:	e8 81 fd ff ff       	call   80104d90 <argint>
8010500f:	83 c4 10             	add    $0x10,%esp
80105012:	85 c0                	test   %eax,%eax
80105014:	78 19                	js     8010502f <sys_read+0x4b>
80105016:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105019:	83 ec 04             	sub    $0x4,%esp
8010501c:	50                   	push   %eax
8010501d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105020:	50                   	push   %eax
80105021:	6a 01                	push   $0x1
80105023:	e8 95 fd ff ff       	call   80104dbd <argptr>
80105028:	83 c4 10             	add    $0x10,%esp
8010502b:	85 c0                	test   %eax,%eax
8010502d:	79 07                	jns    80105036 <sys_read+0x52>
    return -1;
8010502f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105034:	eb 17                	jmp    8010504d <sys_read+0x69>
  return fileread(f, p, n);
80105036:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105039:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010503c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010503f:	83 ec 04             	sub    $0x4,%esp
80105042:	51                   	push   %ecx
80105043:	52                   	push   %edx
80105044:	50                   	push   %eax
80105045:	e8 9a c1 ff ff       	call   801011e4 <fileread>
8010504a:	83 c4 10             	add    $0x10,%esp
}
8010504d:	c9                   	leave
8010504e:	c3                   	ret

8010504f <sys_write>:

int
sys_write(void)
{
8010504f:	55                   	push   %ebp
80105050:	89 e5                	mov    %esp,%ebp
80105052:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105055:	83 ec 04             	sub    $0x4,%esp
80105058:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010505b:	50                   	push   %eax
8010505c:	6a 00                	push   $0x0
8010505e:	6a 00                	push   $0x0
80105060:	e8 66 fe ff ff       	call   80104ecb <argfd>
80105065:	83 c4 10             	add    $0x10,%esp
80105068:	85 c0                	test   %eax,%eax
8010506a:	78 2e                	js     8010509a <sys_write+0x4b>
8010506c:	83 ec 08             	sub    $0x8,%esp
8010506f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105072:	50                   	push   %eax
80105073:	6a 02                	push   $0x2
80105075:	e8 16 fd ff ff       	call   80104d90 <argint>
8010507a:	83 c4 10             	add    $0x10,%esp
8010507d:	85 c0                	test   %eax,%eax
8010507f:	78 19                	js     8010509a <sys_write+0x4b>
80105081:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105084:	83 ec 04             	sub    $0x4,%esp
80105087:	50                   	push   %eax
80105088:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010508b:	50                   	push   %eax
8010508c:	6a 01                	push   $0x1
8010508e:	e8 2a fd ff ff       	call   80104dbd <argptr>
80105093:	83 c4 10             	add    $0x10,%esp
80105096:	85 c0                	test   %eax,%eax
80105098:	79 07                	jns    801050a1 <sys_write+0x52>
    return -1;
8010509a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010509f:	eb 17                	jmp    801050b8 <sys_write+0x69>
  return filewrite(f, p, n);
801050a1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801050a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801050a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050aa:	83 ec 04             	sub    $0x4,%esp
801050ad:	51                   	push   %ecx
801050ae:	52                   	push   %edx
801050af:	50                   	push   %eax
801050b0:	e8 e7 c1 ff ff       	call   8010129c <filewrite>
801050b5:	83 c4 10             	add    $0x10,%esp
}
801050b8:	c9                   	leave
801050b9:	c3                   	ret

801050ba <sys_close>:

int
sys_close(void)
{
801050ba:	55                   	push   %ebp
801050bb:	89 e5                	mov    %esp,%ebp
801050bd:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
801050c0:	83 ec 04             	sub    $0x4,%esp
801050c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801050c6:	50                   	push   %eax
801050c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050ca:	50                   	push   %eax
801050cb:	6a 00                	push   $0x0
801050cd:	e8 f9 fd ff ff       	call   80104ecb <argfd>
801050d2:	83 c4 10             	add    $0x10,%esp
801050d5:	85 c0                	test   %eax,%eax
801050d7:	79 07                	jns    801050e0 <sys_close+0x26>
    return -1;
801050d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050de:	eb 27                	jmp    80105107 <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
801050e0:	e8 4b e9 ff ff       	call   80103a30 <myproc>
801050e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050e8:	83 c2 08             	add    $0x8,%edx
801050eb:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801050f2:	00 
  fileclose(f);
801050f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f6:	83 ec 0c             	sub    $0xc,%esp
801050f9:	50                   	push   %eax
801050fa:	e8 a6 bf ff ff       	call   801010a5 <fileclose>
801050ff:	83 c4 10             	add    $0x10,%esp
  return 0;
80105102:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105107:	c9                   	leave
80105108:	c3                   	ret

80105109 <sys_fstat>:

int
sys_fstat(void)
{
80105109:	55                   	push   %ebp
8010510a:	89 e5                	mov    %esp,%ebp
8010510c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010510f:	83 ec 04             	sub    $0x4,%esp
80105112:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105115:	50                   	push   %eax
80105116:	6a 00                	push   $0x0
80105118:	6a 00                	push   $0x0
8010511a:	e8 ac fd ff ff       	call   80104ecb <argfd>
8010511f:	83 c4 10             	add    $0x10,%esp
80105122:	85 c0                	test   %eax,%eax
80105124:	78 17                	js     8010513d <sys_fstat+0x34>
80105126:	83 ec 04             	sub    $0x4,%esp
80105129:	6a 14                	push   $0x14
8010512b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010512e:	50                   	push   %eax
8010512f:	6a 01                	push   $0x1
80105131:	e8 87 fc ff ff       	call   80104dbd <argptr>
80105136:	83 c4 10             	add    $0x10,%esp
80105139:	85 c0                	test   %eax,%eax
8010513b:	79 07                	jns    80105144 <sys_fstat+0x3b>
    return -1;
8010513d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105142:	eb 13                	jmp    80105157 <sys_fstat+0x4e>
  return filestat(f, st);
80105144:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105147:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514a:	83 ec 08             	sub    $0x8,%esp
8010514d:	52                   	push   %edx
8010514e:	50                   	push   %eax
8010514f:	e8 39 c0 ff ff       	call   8010118d <filestat>
80105154:	83 c4 10             	add    $0x10,%esp
}
80105157:	c9                   	leave
80105158:	c3                   	ret

80105159 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105159:	55                   	push   %ebp
8010515a:	89 e5                	mov    %esp,%ebp
8010515c:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010515f:	83 ec 08             	sub    $0x8,%esp
80105162:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105165:	50                   	push   %eax
80105166:	6a 00                	push   $0x0
80105168:	e8 a9 fc ff ff       	call   80104e16 <argstr>
8010516d:	83 c4 10             	add    $0x10,%esp
80105170:	85 c0                	test   %eax,%eax
80105172:	78 15                	js     80105189 <sys_link+0x30>
80105174:	83 ec 08             	sub    $0x8,%esp
80105177:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010517a:	50                   	push   %eax
8010517b:	6a 01                	push   $0x1
8010517d:	e8 94 fc ff ff       	call   80104e16 <argstr>
80105182:	83 c4 10             	add    $0x10,%esp
80105185:	85 c0                	test   %eax,%eax
80105187:	79 0a                	jns    80105193 <sys_link+0x3a>
    return -1;
80105189:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010518e:	e9 68 01 00 00       	jmp    801052fb <sys_link+0x1a2>

  begin_op();
80105193:	e8 a6 de ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
80105198:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010519b:	83 ec 0c             	sub    $0xc,%esp
8010519e:	50                   	push   %eax
8010519f:	e8 81 d3 ff ff       	call   80102525 <namei>
801051a4:	83 c4 10             	add    $0x10,%esp
801051a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801051aa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801051ae:	75 0f                	jne    801051bf <sys_link+0x66>
    end_op();
801051b0:	e8 15 df ff ff       	call   801030ca <end_op>
    return -1;
801051b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ba:	e9 3c 01 00 00       	jmp    801052fb <sys_link+0x1a2>
  }

  ilock(ip);
801051bf:	83 ec 0c             	sub    $0xc,%esp
801051c2:	ff 75 f4             	push   -0xc(%ebp)
801051c5:	e8 28 c8 ff ff       	call   801019f2 <ilock>
801051ca:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
801051cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051d0:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801051d4:	66 83 f8 01          	cmp    $0x1,%ax
801051d8:	75 1d                	jne    801051f7 <sys_link+0x9e>
    iunlockput(ip);
801051da:	83 ec 0c             	sub    $0xc,%esp
801051dd:	ff 75 f4             	push   -0xc(%ebp)
801051e0:	e8 3e ca ff ff       	call   80101c23 <iunlockput>
801051e5:	83 c4 10             	add    $0x10,%esp
    end_op();
801051e8:	e8 dd de ff ff       	call   801030ca <end_op>
    return -1;
801051ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f2:	e9 04 01 00 00       	jmp    801052fb <sys_link+0x1a2>
  }

  ip->nlink++;
801051f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fa:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051fe:	83 c0 01             	add    $0x1,%eax
80105201:	89 c2                	mov    %eax,%edx
80105203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105206:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010520a:	83 ec 0c             	sub    $0xc,%esp
8010520d:	ff 75 f4             	push   -0xc(%ebp)
80105210:	e8 00 c6 ff ff       	call   80101815 <iupdate>
80105215:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105218:	83 ec 0c             	sub    $0xc,%esp
8010521b:	ff 75 f4             	push   -0xc(%ebp)
8010521e:	e8 e2 c8 ff ff       	call   80101b05 <iunlock>
80105223:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105226:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105229:	83 ec 08             	sub    $0x8,%esp
8010522c:	8d 55 e2             	lea    -0x1e(%ebp),%edx
8010522f:	52                   	push   %edx
80105230:	50                   	push   %eax
80105231:	e8 0b d3 ff ff       	call   80102541 <nameiparent>
80105236:	83 c4 10             	add    $0x10,%esp
80105239:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010523c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105240:	74 71                	je     801052b3 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105242:	83 ec 0c             	sub    $0xc,%esp
80105245:	ff 75 f0             	push   -0x10(%ebp)
80105248:	e8 a5 c7 ff ff       	call   801019f2 <ilock>
8010524d:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105250:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105253:	8b 10                	mov    (%eax),%edx
80105255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105258:	8b 00                	mov    (%eax),%eax
8010525a:	39 c2                	cmp    %eax,%edx
8010525c:	75 1d                	jne    8010527b <sys_link+0x122>
8010525e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105261:	8b 40 04             	mov    0x4(%eax),%eax
80105264:	83 ec 04             	sub    $0x4,%esp
80105267:	50                   	push   %eax
80105268:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010526b:	50                   	push   %eax
8010526c:	ff 75 f0             	push   -0x10(%ebp)
8010526f:	e8 1a d0 ff ff       	call   8010228e <dirlink>
80105274:	83 c4 10             	add    $0x10,%esp
80105277:	85 c0                	test   %eax,%eax
80105279:	79 10                	jns    8010528b <sys_link+0x132>
    iunlockput(dp);
8010527b:	83 ec 0c             	sub    $0xc,%esp
8010527e:	ff 75 f0             	push   -0x10(%ebp)
80105281:	e8 9d c9 ff ff       	call   80101c23 <iunlockput>
80105286:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105289:	eb 29                	jmp    801052b4 <sys_link+0x15b>
  }
  iunlockput(dp);
8010528b:	83 ec 0c             	sub    $0xc,%esp
8010528e:	ff 75 f0             	push   -0x10(%ebp)
80105291:	e8 8d c9 ff ff       	call   80101c23 <iunlockput>
80105296:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105299:	83 ec 0c             	sub    $0xc,%esp
8010529c:	ff 75 f4             	push   -0xc(%ebp)
8010529f:	e8 af c8 ff ff       	call   80101b53 <iput>
801052a4:	83 c4 10             	add    $0x10,%esp

  end_op();
801052a7:	e8 1e de ff ff       	call   801030ca <end_op>

  return 0;
801052ac:	b8 00 00 00 00       	mov    $0x0,%eax
801052b1:	eb 48                	jmp    801052fb <sys_link+0x1a2>
    goto bad;
801052b3:	90                   	nop

bad:
  ilock(ip);
801052b4:	83 ec 0c             	sub    $0xc,%esp
801052b7:	ff 75 f4             	push   -0xc(%ebp)
801052ba:	e8 33 c7 ff ff       	call   801019f2 <ilock>
801052bf:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801052c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052c5:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801052c9:	83 e8 01             	sub    $0x1,%eax
801052cc:	89 c2                	mov    %eax,%edx
801052ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d1:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
801052d5:	83 ec 0c             	sub    $0xc,%esp
801052d8:	ff 75 f4             	push   -0xc(%ebp)
801052db:	e8 35 c5 ff ff       	call   80101815 <iupdate>
801052e0:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
801052e3:	83 ec 0c             	sub    $0xc,%esp
801052e6:	ff 75 f4             	push   -0xc(%ebp)
801052e9:	e8 35 c9 ff ff       	call   80101c23 <iunlockput>
801052ee:	83 c4 10             	add    $0x10,%esp
  end_op();
801052f1:	e8 d4 dd ff ff       	call   801030ca <end_op>
  return -1;
801052f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801052fb:	c9                   	leave
801052fc:	c3                   	ret

801052fd <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801052fd:	55                   	push   %ebp
801052fe:	89 e5                	mov    %esp,%ebp
80105300:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105303:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010530a:	eb 40                	jmp    8010534c <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010530c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010530f:	6a 10                	push   $0x10
80105311:	50                   	push   %eax
80105312:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105315:	50                   	push   %eax
80105316:	ff 75 08             	push   0x8(%ebp)
80105319:	e8 c0 cb ff ff       	call   80101ede <readi>
8010531e:	83 c4 10             	add    $0x10,%esp
80105321:	83 f8 10             	cmp    $0x10,%eax
80105324:	74 0d                	je     80105333 <isdirempty+0x36>
      panic("isdirempty: readi");
80105326:	83 ec 0c             	sub    $0xc,%esp
80105329:	68 66 a5 10 80       	push   $0x8010a566
8010532e:	e8 8e b2 ff ff       	call   801005c1 <panic>
    if(de.inum != 0)
80105333:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105337:	66 85 c0             	test   %ax,%ax
8010533a:	74 07                	je     80105343 <isdirempty+0x46>
      return 0;
8010533c:	b8 00 00 00 00       	mov    $0x0,%eax
80105341:	eb 1b                	jmp    8010535e <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105346:	83 c0 10             	add    $0x10,%eax
80105349:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010534c:	8b 45 08             	mov    0x8(%ebp),%eax
8010534f:	8b 40 58             	mov    0x58(%eax),%eax
80105352:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105355:	39 c2                	cmp    %eax,%edx
80105357:	72 b3                	jb     8010530c <isdirempty+0xf>
  }
  return 1;
80105359:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010535e:	c9                   	leave
8010535f:	c3                   	ret

80105360 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105360:	55                   	push   %ebp
80105361:	89 e5                	mov    %esp,%ebp
80105363:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105366:	83 ec 08             	sub    $0x8,%esp
80105369:	8d 45 cc             	lea    -0x34(%ebp),%eax
8010536c:	50                   	push   %eax
8010536d:	6a 00                	push   $0x0
8010536f:	e8 a2 fa ff ff       	call   80104e16 <argstr>
80105374:	83 c4 10             	add    $0x10,%esp
80105377:	85 c0                	test   %eax,%eax
80105379:	79 0a                	jns    80105385 <sys_unlink+0x25>
    return -1;
8010537b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105380:	e9 bf 01 00 00       	jmp    80105544 <sys_unlink+0x1e4>

  begin_op();
80105385:	e8 b4 dc ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010538a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010538d:	83 ec 08             	sub    $0x8,%esp
80105390:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105393:	52                   	push   %edx
80105394:	50                   	push   %eax
80105395:	e8 a7 d1 ff ff       	call   80102541 <nameiparent>
8010539a:	83 c4 10             	add    $0x10,%esp
8010539d:	89 45 f4             	mov    %eax,-0xc(%ebp)
801053a0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801053a4:	75 0f                	jne    801053b5 <sys_unlink+0x55>
    end_op();
801053a6:	e8 1f dd ff ff       	call   801030ca <end_op>
    return -1;
801053ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053b0:	e9 8f 01 00 00       	jmp    80105544 <sys_unlink+0x1e4>
  }

  ilock(dp);
801053b5:	83 ec 0c             	sub    $0xc,%esp
801053b8:	ff 75 f4             	push   -0xc(%ebp)
801053bb:	e8 32 c6 ff ff       	call   801019f2 <ilock>
801053c0:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801053c3:	83 ec 08             	sub    $0x8,%esp
801053c6:	68 78 a5 10 80       	push   $0x8010a578
801053cb:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053ce:	50                   	push   %eax
801053cf:	e8 e5 cd ff ff       	call   801021b9 <namecmp>
801053d4:	83 c4 10             	add    $0x10,%esp
801053d7:	85 c0                	test   %eax,%eax
801053d9:	0f 84 49 01 00 00    	je     80105528 <sys_unlink+0x1c8>
801053df:	83 ec 08             	sub    $0x8,%esp
801053e2:	68 7a a5 10 80       	push   $0x8010a57a
801053e7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801053ea:	50                   	push   %eax
801053eb:	e8 c9 cd ff ff       	call   801021b9 <namecmp>
801053f0:	83 c4 10             	add    $0x10,%esp
801053f3:	85 c0                	test   %eax,%eax
801053f5:	0f 84 2d 01 00 00    	je     80105528 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801053fb:	83 ec 04             	sub    $0x4,%esp
801053fe:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105401:	50                   	push   %eax
80105402:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105405:	50                   	push   %eax
80105406:	ff 75 f4             	push   -0xc(%ebp)
80105409:	e8 c6 cd ff ff       	call   801021d4 <dirlookup>
8010540e:	83 c4 10             	add    $0x10,%esp
80105411:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105414:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105418:	0f 84 0d 01 00 00    	je     8010552b <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
8010541e:	83 ec 0c             	sub    $0xc,%esp
80105421:	ff 75 f0             	push   -0x10(%ebp)
80105424:	e8 c9 c5 ff ff       	call   801019f2 <ilock>
80105429:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
8010542c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542f:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105433:	66 85 c0             	test   %ax,%ax
80105436:	7f 0d                	jg     80105445 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105438:	83 ec 0c             	sub    $0xc,%esp
8010543b:	68 7d a5 10 80       	push   $0x8010a57d
80105440:	e8 7c b1 ff ff       	call   801005c1 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105445:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105448:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010544c:	66 83 f8 01          	cmp    $0x1,%ax
80105450:	75 25                	jne    80105477 <sys_unlink+0x117>
80105452:	83 ec 0c             	sub    $0xc,%esp
80105455:	ff 75 f0             	push   -0x10(%ebp)
80105458:	e8 a0 fe ff ff       	call   801052fd <isdirempty>
8010545d:	83 c4 10             	add    $0x10,%esp
80105460:	85 c0                	test   %eax,%eax
80105462:	75 13                	jne    80105477 <sys_unlink+0x117>
    iunlockput(ip);
80105464:	83 ec 0c             	sub    $0xc,%esp
80105467:	ff 75 f0             	push   -0x10(%ebp)
8010546a:	e8 b4 c7 ff ff       	call   80101c23 <iunlockput>
8010546f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105472:	e9 b5 00 00 00       	jmp    8010552c <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105477:	83 ec 04             	sub    $0x4,%esp
8010547a:	6a 10                	push   $0x10
8010547c:	6a 00                	push   $0x0
8010547e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105481:	50                   	push   %eax
80105482:	e8 fa f5 ff ff       	call   80104a81 <memset>
80105487:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010548a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010548d:	6a 10                	push   $0x10
8010548f:	50                   	push   %eax
80105490:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105493:	50                   	push   %eax
80105494:	ff 75 f4             	push   -0xc(%ebp)
80105497:	e8 97 cb ff ff       	call   80102033 <writei>
8010549c:	83 c4 10             	add    $0x10,%esp
8010549f:	83 f8 10             	cmp    $0x10,%eax
801054a2:	74 0d                	je     801054b1 <sys_unlink+0x151>
    panic("unlink: writei");
801054a4:	83 ec 0c             	sub    $0xc,%esp
801054a7:	68 8f a5 10 80       	push   $0x8010a58f
801054ac:	e8 10 b1 ff ff       	call   801005c1 <panic>
  if(ip->type == T_DIR){
801054b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054b4:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801054b8:	66 83 f8 01          	cmp    $0x1,%ax
801054bc:	75 21                	jne    801054df <sys_unlink+0x17f>
    dp->nlink--;
801054be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054c1:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054c5:	83 e8 01             	sub    $0x1,%eax
801054c8:	89 c2                	mov    %eax,%edx
801054ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801054cd:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801054d1:	83 ec 0c             	sub    $0xc,%esp
801054d4:	ff 75 f4             	push   -0xc(%ebp)
801054d7:	e8 39 c3 ff ff       	call   80101815 <iupdate>
801054dc:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
801054df:	83 ec 0c             	sub    $0xc,%esp
801054e2:	ff 75 f4             	push   -0xc(%ebp)
801054e5:	e8 39 c7 ff ff       	call   80101c23 <iunlockput>
801054ea:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
801054ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054f0:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801054f4:	83 e8 01             	sub    $0x1,%eax
801054f7:	89 c2                	mov    %eax,%edx
801054f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054fc:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105500:	83 ec 0c             	sub    $0xc,%esp
80105503:	ff 75 f0             	push   -0x10(%ebp)
80105506:	e8 0a c3 ff ff       	call   80101815 <iupdate>
8010550b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010550e:	83 ec 0c             	sub    $0xc,%esp
80105511:	ff 75 f0             	push   -0x10(%ebp)
80105514:	e8 0a c7 ff ff       	call   80101c23 <iunlockput>
80105519:	83 c4 10             	add    $0x10,%esp

  end_op();
8010551c:	e8 a9 db ff ff       	call   801030ca <end_op>

  return 0;
80105521:	b8 00 00 00 00       	mov    $0x0,%eax
80105526:	eb 1c                	jmp    80105544 <sys_unlink+0x1e4>
    goto bad;
80105528:	90                   	nop
80105529:	eb 01                	jmp    8010552c <sys_unlink+0x1cc>
    goto bad;
8010552b:	90                   	nop

bad:
  iunlockput(dp);
8010552c:	83 ec 0c             	sub    $0xc,%esp
8010552f:	ff 75 f4             	push   -0xc(%ebp)
80105532:	e8 ec c6 ff ff       	call   80101c23 <iunlockput>
80105537:	83 c4 10             	add    $0x10,%esp
  end_op();
8010553a:	e8 8b db ff ff       	call   801030ca <end_op>
  return -1;
8010553f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105544:	c9                   	leave
80105545:	c3                   	ret

80105546 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105546:	55                   	push   %ebp
80105547:	89 e5                	mov    %esp,%ebp
80105549:	83 ec 38             	sub    $0x38,%esp
8010554c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010554f:	8b 55 10             	mov    0x10(%ebp),%edx
80105552:	8b 45 14             	mov    0x14(%ebp),%eax
80105555:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105559:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010555d:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105561:	83 ec 08             	sub    $0x8,%esp
80105564:	8d 45 de             	lea    -0x22(%ebp),%eax
80105567:	50                   	push   %eax
80105568:	ff 75 08             	push   0x8(%ebp)
8010556b:	e8 d1 cf ff ff       	call   80102541 <nameiparent>
80105570:	83 c4 10             	add    $0x10,%esp
80105573:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105576:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010557a:	75 0a                	jne    80105586 <create+0x40>
    return 0;
8010557c:	b8 00 00 00 00       	mov    $0x0,%eax
80105581:	e9 90 01 00 00       	jmp    80105716 <create+0x1d0>
  ilock(dp);
80105586:	83 ec 0c             	sub    $0xc,%esp
80105589:	ff 75 f4             	push   -0xc(%ebp)
8010558c:	e8 61 c4 ff ff       	call   801019f2 <ilock>
80105591:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105594:	83 ec 04             	sub    $0x4,%esp
80105597:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010559a:	50                   	push   %eax
8010559b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010559e:	50                   	push   %eax
8010559f:	ff 75 f4             	push   -0xc(%ebp)
801055a2:	e8 2d cc ff ff       	call   801021d4 <dirlookup>
801055a7:	83 c4 10             	add    $0x10,%esp
801055aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801055ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801055b1:	74 50                	je     80105603 <create+0xbd>
    iunlockput(dp);
801055b3:	83 ec 0c             	sub    $0xc,%esp
801055b6:	ff 75 f4             	push   -0xc(%ebp)
801055b9:	e8 65 c6 ff ff       	call   80101c23 <iunlockput>
801055be:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801055c1:	83 ec 0c             	sub    $0xc,%esp
801055c4:	ff 75 f0             	push   -0x10(%ebp)
801055c7:	e8 26 c4 ff ff       	call   801019f2 <ilock>
801055cc:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
801055cf:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801055d4:	75 15                	jne    801055eb <create+0xa5>
801055d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055d9:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801055dd:	66 83 f8 02          	cmp    $0x2,%ax
801055e1:	75 08                	jne    801055eb <create+0xa5>
      return ip;
801055e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055e6:	e9 2b 01 00 00       	jmp    80105716 <create+0x1d0>
    iunlockput(ip);
801055eb:	83 ec 0c             	sub    $0xc,%esp
801055ee:	ff 75 f0             	push   -0x10(%ebp)
801055f1:	e8 2d c6 ff ff       	call   80101c23 <iunlockput>
801055f6:	83 c4 10             	add    $0x10,%esp
    return 0;
801055f9:	b8 00 00 00 00       	mov    $0x0,%eax
801055fe:	e9 13 01 00 00       	jmp    80105716 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105603:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010560a:	8b 00                	mov    (%eax),%eax
8010560c:	83 ec 08             	sub    $0x8,%esp
8010560f:	52                   	push   %edx
80105610:	50                   	push   %eax
80105611:	e8 29 c1 ff ff       	call   8010173f <ialloc>
80105616:	83 c4 10             	add    $0x10,%esp
80105619:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010561c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105620:	75 0d                	jne    8010562f <create+0xe9>
    panic("create: ialloc");
80105622:	83 ec 0c             	sub    $0xc,%esp
80105625:	68 9e a5 10 80       	push   $0x8010a59e
8010562a:	e8 92 af ff ff       	call   801005c1 <panic>

  ilock(ip);
8010562f:	83 ec 0c             	sub    $0xc,%esp
80105632:	ff 75 f0             	push   -0x10(%ebp)
80105635:	e8 b8 c3 ff ff       	call   801019f2 <ilock>
8010563a:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
8010563d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105640:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105644:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
80105648:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010564b:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
8010564f:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105653:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105656:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
8010565c:	83 ec 0c             	sub    $0xc,%esp
8010565f:	ff 75 f0             	push   -0x10(%ebp)
80105662:	e8 ae c1 ff ff       	call   80101815 <iupdate>
80105667:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
8010566a:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010566f:	75 6a                	jne    801056db <create+0x195>
    dp->nlink++;  // for ".."
80105671:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105674:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105678:	83 c0 01             	add    $0x1,%eax
8010567b:	89 c2                	mov    %eax,%edx
8010567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105680:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105684:	83 ec 0c             	sub    $0xc,%esp
80105687:	ff 75 f4             	push   -0xc(%ebp)
8010568a:	e8 86 c1 ff ff       	call   80101815 <iupdate>
8010568f:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105692:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105695:	8b 40 04             	mov    0x4(%eax),%eax
80105698:	83 ec 04             	sub    $0x4,%esp
8010569b:	50                   	push   %eax
8010569c:	68 78 a5 10 80       	push   $0x8010a578
801056a1:	ff 75 f0             	push   -0x10(%ebp)
801056a4:	e8 e5 cb ff ff       	call   8010228e <dirlink>
801056a9:	83 c4 10             	add    $0x10,%esp
801056ac:	85 c0                	test   %eax,%eax
801056ae:	78 1e                	js     801056ce <create+0x188>
801056b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b3:	8b 40 04             	mov    0x4(%eax),%eax
801056b6:	83 ec 04             	sub    $0x4,%esp
801056b9:	50                   	push   %eax
801056ba:	68 7a a5 10 80       	push   $0x8010a57a
801056bf:	ff 75 f0             	push   -0x10(%ebp)
801056c2:	e8 c7 cb ff ff       	call   8010228e <dirlink>
801056c7:	83 c4 10             	add    $0x10,%esp
801056ca:	85 c0                	test   %eax,%eax
801056cc:	79 0d                	jns    801056db <create+0x195>
      panic("create dots");
801056ce:	83 ec 0c             	sub    $0xc,%esp
801056d1:	68 ad a5 10 80       	push   $0x8010a5ad
801056d6:	e8 e6 ae ff ff       	call   801005c1 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801056db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056de:	8b 40 04             	mov    0x4(%eax),%eax
801056e1:	83 ec 04             	sub    $0x4,%esp
801056e4:	50                   	push   %eax
801056e5:	8d 45 de             	lea    -0x22(%ebp),%eax
801056e8:	50                   	push   %eax
801056e9:	ff 75 f4             	push   -0xc(%ebp)
801056ec:	e8 9d cb ff ff       	call   8010228e <dirlink>
801056f1:	83 c4 10             	add    $0x10,%esp
801056f4:	85 c0                	test   %eax,%eax
801056f6:	79 0d                	jns    80105705 <create+0x1bf>
    panic("create: dirlink");
801056f8:	83 ec 0c             	sub    $0xc,%esp
801056fb:	68 b9 a5 10 80       	push   $0x8010a5b9
80105700:	e8 bc ae ff ff       	call   801005c1 <panic>

  iunlockput(dp);
80105705:	83 ec 0c             	sub    $0xc,%esp
80105708:	ff 75 f4             	push   -0xc(%ebp)
8010570b:	e8 13 c5 ff ff       	call   80101c23 <iunlockput>
80105710:	83 c4 10             	add    $0x10,%esp

  return ip;
80105713:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105716:	c9                   	leave
80105717:	c3                   	ret

80105718 <sys_open>:

int
sys_open(void)
{
80105718:	55                   	push   %ebp
80105719:	89 e5                	mov    %esp,%ebp
8010571b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010571e:	83 ec 08             	sub    $0x8,%esp
80105721:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105724:	50                   	push   %eax
80105725:	6a 00                	push   $0x0
80105727:	e8 ea f6 ff ff       	call   80104e16 <argstr>
8010572c:	83 c4 10             	add    $0x10,%esp
8010572f:	85 c0                	test   %eax,%eax
80105731:	78 15                	js     80105748 <sys_open+0x30>
80105733:	83 ec 08             	sub    $0x8,%esp
80105736:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105739:	50                   	push   %eax
8010573a:	6a 01                	push   $0x1
8010573c:	e8 4f f6 ff ff       	call   80104d90 <argint>
80105741:	83 c4 10             	add    $0x10,%esp
80105744:	85 c0                	test   %eax,%eax
80105746:	79 0a                	jns    80105752 <sys_open+0x3a>
    return -1;
80105748:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010574d:	e9 61 01 00 00       	jmp    801058b3 <sys_open+0x19b>

  begin_op();
80105752:	e8 e7 d8 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
80105757:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010575a:	25 00 02 00 00       	and    $0x200,%eax
8010575f:	85 c0                	test   %eax,%eax
80105761:	74 2a                	je     8010578d <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105763:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105766:	6a 00                	push   $0x0
80105768:	6a 00                	push   $0x0
8010576a:	6a 02                	push   $0x2
8010576c:	50                   	push   %eax
8010576d:	e8 d4 fd ff ff       	call   80105546 <create>
80105772:	83 c4 10             	add    $0x10,%esp
80105775:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105778:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010577c:	75 75                	jne    801057f3 <sys_open+0xdb>
      end_op();
8010577e:	e8 47 d9 ff ff       	call   801030ca <end_op>
      return -1;
80105783:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105788:	e9 26 01 00 00       	jmp    801058b3 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010578d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105790:	83 ec 0c             	sub    $0xc,%esp
80105793:	50                   	push   %eax
80105794:	e8 8c cd ff ff       	call   80102525 <namei>
80105799:	83 c4 10             	add    $0x10,%esp
8010579c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010579f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057a3:	75 0f                	jne    801057b4 <sys_open+0x9c>
      end_op();
801057a5:	e8 20 d9 ff ff       	call   801030ca <end_op>
      return -1;
801057aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057af:	e9 ff 00 00 00       	jmp    801058b3 <sys_open+0x19b>
    }
    ilock(ip);
801057b4:	83 ec 0c             	sub    $0xc,%esp
801057b7:	ff 75 f4             	push   -0xc(%ebp)
801057ba:	e8 33 c2 ff ff       	call   801019f2 <ilock>
801057bf:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801057c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057c5:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801057c9:	66 83 f8 01          	cmp    $0x1,%ax
801057cd:	75 24                	jne    801057f3 <sys_open+0xdb>
801057cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057d2:	85 c0                	test   %eax,%eax
801057d4:	74 1d                	je     801057f3 <sys_open+0xdb>
      iunlockput(ip);
801057d6:	83 ec 0c             	sub    $0xc,%esp
801057d9:	ff 75 f4             	push   -0xc(%ebp)
801057dc:	e8 42 c4 ff ff       	call   80101c23 <iunlockput>
801057e1:	83 c4 10             	add    $0x10,%esp
      end_op();
801057e4:	e8 e1 d8 ff ff       	call   801030ca <end_op>
      return -1;
801057e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057ee:	e9 c0 00 00 00       	jmp    801058b3 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801057f3:	e8 ef b7 ff ff       	call   80100fe7 <filealloc>
801057f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801057fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057ff:	74 17                	je     80105818 <sys_open+0x100>
80105801:	83 ec 0c             	sub    $0xc,%esp
80105804:	ff 75 f0             	push   -0x10(%ebp)
80105807:	e8 33 f7 ff ff       	call   80104f3f <fdalloc>
8010580c:	83 c4 10             	add    $0x10,%esp
8010580f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105812:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105816:	79 2e                	jns    80105846 <sys_open+0x12e>
    if(f)
80105818:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010581c:	74 0e                	je     8010582c <sys_open+0x114>
      fileclose(f);
8010581e:	83 ec 0c             	sub    $0xc,%esp
80105821:	ff 75 f0             	push   -0x10(%ebp)
80105824:	e8 7c b8 ff ff       	call   801010a5 <fileclose>
80105829:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010582c:	83 ec 0c             	sub    $0xc,%esp
8010582f:	ff 75 f4             	push   -0xc(%ebp)
80105832:	e8 ec c3 ff ff       	call   80101c23 <iunlockput>
80105837:	83 c4 10             	add    $0x10,%esp
    end_op();
8010583a:	e8 8b d8 ff ff       	call   801030ca <end_op>
    return -1;
8010583f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105844:	eb 6d                	jmp    801058b3 <sys_open+0x19b>
  }
  iunlock(ip);
80105846:	83 ec 0c             	sub    $0xc,%esp
80105849:	ff 75 f4             	push   -0xc(%ebp)
8010584c:	e8 b4 c2 ff ff       	call   80101b05 <iunlock>
80105851:	83 c4 10             	add    $0x10,%esp
  end_op();
80105854:	e8 71 d8 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
80105859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010585c:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105865:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105868:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010586b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010586e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80105875:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105878:	83 e0 01             	and    $0x1,%eax
8010587b:	85 c0                	test   %eax,%eax
8010587d:	0f 94 c0             	sete   %al
80105880:	89 c2                	mov    %eax,%edx
80105882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105885:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80105888:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010588b:	83 e0 01             	and    $0x1,%eax
8010588e:	85 c0                	test   %eax,%eax
80105890:	75 0a                	jne    8010589c <sys_open+0x184>
80105892:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105895:	83 e0 02             	and    $0x2,%eax
80105898:	85 c0                	test   %eax,%eax
8010589a:	74 07                	je     801058a3 <sys_open+0x18b>
8010589c:	b8 01 00 00 00       	mov    $0x1,%eax
801058a1:	eb 05                	jmp    801058a8 <sys_open+0x190>
801058a3:	b8 00 00 00 00       	mov    $0x0,%eax
801058a8:	89 c2                	mov    %eax,%edx
801058aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058ad:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801058b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801058b3:	c9                   	leave
801058b4:	c3                   	ret

801058b5 <sys_mkdir>:

int
sys_mkdir(void)
{
801058b5:	55                   	push   %ebp
801058b6:	89 e5                	mov    %esp,%ebp
801058b8:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801058bb:	e8 7e d7 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801058c0:	83 ec 08             	sub    $0x8,%esp
801058c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058c6:	50                   	push   %eax
801058c7:	6a 00                	push   $0x0
801058c9:	e8 48 f5 ff ff       	call   80104e16 <argstr>
801058ce:	83 c4 10             	add    $0x10,%esp
801058d1:	85 c0                	test   %eax,%eax
801058d3:	78 1b                	js     801058f0 <sys_mkdir+0x3b>
801058d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058d8:	6a 00                	push   $0x0
801058da:	6a 00                	push   $0x0
801058dc:	6a 01                	push   $0x1
801058de:	50                   	push   %eax
801058df:	e8 62 fc ff ff       	call   80105546 <create>
801058e4:	83 c4 10             	add    $0x10,%esp
801058e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058ee:	75 0c                	jne    801058fc <sys_mkdir+0x47>
    end_op();
801058f0:	e8 d5 d7 ff ff       	call   801030ca <end_op>
    return -1;
801058f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058fa:	eb 18                	jmp    80105914 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
801058fc:	83 ec 0c             	sub    $0xc,%esp
801058ff:	ff 75 f4             	push   -0xc(%ebp)
80105902:	e8 1c c3 ff ff       	call   80101c23 <iunlockput>
80105907:	83 c4 10             	add    $0x10,%esp
  end_op();
8010590a:	e8 bb d7 ff ff       	call   801030ca <end_op>
  return 0;
8010590f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105914:	c9                   	leave
80105915:	c3                   	ret

80105916 <sys_mknod>:

int
sys_mknod(void)
{
80105916:	55                   	push   %ebp
80105917:	89 e5                	mov    %esp,%ebp
80105919:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010591c:	e8 1d d7 ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
80105921:	83 ec 08             	sub    $0x8,%esp
80105924:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105927:	50                   	push   %eax
80105928:	6a 00                	push   $0x0
8010592a:	e8 e7 f4 ff ff       	call   80104e16 <argstr>
8010592f:	83 c4 10             	add    $0x10,%esp
80105932:	85 c0                	test   %eax,%eax
80105934:	78 4f                	js     80105985 <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
80105936:	83 ec 08             	sub    $0x8,%esp
80105939:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010593c:	50                   	push   %eax
8010593d:	6a 01                	push   $0x1
8010593f:	e8 4c f4 ff ff       	call   80104d90 <argint>
80105944:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
80105947:	85 c0                	test   %eax,%eax
80105949:	78 3a                	js     80105985 <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
8010594b:	83 ec 08             	sub    $0x8,%esp
8010594e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105951:	50                   	push   %eax
80105952:	6a 02                	push   $0x2
80105954:	e8 37 f4 ff ff       	call   80104d90 <argint>
80105959:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010595c:	85 c0                	test   %eax,%eax
8010595e:	78 25                	js     80105985 <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105960:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105963:	0f bf c8             	movswl %ax,%ecx
80105966:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105969:	0f bf d0             	movswl %ax,%edx
8010596c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010596f:	51                   	push   %ecx
80105970:	52                   	push   %edx
80105971:	6a 03                	push   $0x3
80105973:	50                   	push   %eax
80105974:	e8 cd fb ff ff       	call   80105546 <create>
80105979:	83 c4 10             	add    $0x10,%esp
8010597c:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
8010597f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105983:	75 0c                	jne    80105991 <sys_mknod+0x7b>
    end_op();
80105985:	e8 40 d7 ff ff       	call   801030ca <end_op>
    return -1;
8010598a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010598f:	eb 18                	jmp    801059a9 <sys_mknod+0x93>
  }
  iunlockput(ip);
80105991:	83 ec 0c             	sub    $0xc,%esp
80105994:	ff 75 f4             	push   -0xc(%ebp)
80105997:	e8 87 c2 ff ff       	call   80101c23 <iunlockput>
8010599c:	83 c4 10             	add    $0x10,%esp
  end_op();
8010599f:	e8 26 d7 ff ff       	call   801030ca <end_op>
  return 0;
801059a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801059a9:	c9                   	leave
801059aa:	c3                   	ret

801059ab <sys_chdir>:

int
sys_chdir(void)
{
801059ab:	55                   	push   %ebp
801059ac:	89 e5                	mov    %esp,%ebp
801059ae:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801059b1:	e8 7a e0 ff ff       	call   80103a30 <myproc>
801059b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801059b9:	e8 80 d6 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801059be:	83 ec 08             	sub    $0x8,%esp
801059c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059c4:	50                   	push   %eax
801059c5:	6a 00                	push   $0x0
801059c7:	e8 4a f4 ff ff       	call   80104e16 <argstr>
801059cc:	83 c4 10             	add    $0x10,%esp
801059cf:	85 c0                	test   %eax,%eax
801059d1:	78 18                	js     801059eb <sys_chdir+0x40>
801059d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059d6:	83 ec 0c             	sub    $0xc,%esp
801059d9:	50                   	push   %eax
801059da:	e8 46 cb ff ff       	call   80102525 <namei>
801059df:	83 c4 10             	add    $0x10,%esp
801059e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801059e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801059e9:	75 0c                	jne    801059f7 <sys_chdir+0x4c>
    end_op();
801059eb:	e8 da d6 ff ff       	call   801030ca <end_op>
    return -1;
801059f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f5:	eb 68                	jmp    80105a5f <sys_chdir+0xb4>
  }
  ilock(ip);
801059f7:	83 ec 0c             	sub    $0xc,%esp
801059fa:	ff 75 f0             	push   -0x10(%ebp)
801059fd:	e8 f0 bf ff ff       	call   801019f2 <ilock>
80105a02:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80105a05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a08:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105a0c:	66 83 f8 01          	cmp    $0x1,%ax
80105a10:	74 1a                	je     80105a2c <sys_chdir+0x81>
    iunlockput(ip);
80105a12:	83 ec 0c             	sub    $0xc,%esp
80105a15:	ff 75 f0             	push   -0x10(%ebp)
80105a18:	e8 06 c2 ff ff       	call   80101c23 <iunlockput>
80105a1d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a20:	e8 a5 d6 ff ff       	call   801030ca <end_op>
    return -1;
80105a25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2a:	eb 33                	jmp    80105a5f <sys_chdir+0xb4>
  }
  iunlock(ip);
80105a2c:	83 ec 0c             	sub    $0xc,%esp
80105a2f:	ff 75 f0             	push   -0x10(%ebp)
80105a32:	e8 ce c0 ff ff       	call   80101b05 <iunlock>
80105a37:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a3d:	8b 40 68             	mov    0x68(%eax),%eax
80105a40:	83 ec 0c             	sub    $0xc,%esp
80105a43:	50                   	push   %eax
80105a44:	e8 0a c1 ff ff       	call   80101b53 <iput>
80105a49:	83 c4 10             	add    $0x10,%esp
  end_op();
80105a4c:	e8 79 d6 ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
80105a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a54:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105a57:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105a5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a5f:	c9                   	leave
80105a60:	c3                   	ret

80105a61 <sys_exec>:

int
sys_exec(void)
{
80105a61:	55                   	push   %ebp
80105a62:	89 e5                	mov    %esp,%ebp
80105a64:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105a6a:	83 ec 08             	sub    $0x8,%esp
80105a6d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a70:	50                   	push   %eax
80105a71:	6a 00                	push   $0x0
80105a73:	e8 9e f3 ff ff       	call   80104e16 <argstr>
80105a78:	83 c4 10             	add    $0x10,%esp
80105a7b:	85 c0                	test   %eax,%eax
80105a7d:	78 18                	js     80105a97 <sys_exec+0x36>
80105a7f:	83 ec 08             	sub    $0x8,%esp
80105a82:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80105a88:	50                   	push   %eax
80105a89:	6a 01                	push   $0x1
80105a8b:	e8 00 f3 ff ff       	call   80104d90 <argint>
80105a90:	83 c4 10             	add    $0x10,%esp
80105a93:	85 c0                	test   %eax,%eax
80105a95:	79 0a                	jns    80105aa1 <sys_exec+0x40>
    return -1;
80105a97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9c:	e9 c6 00 00 00       	jmp    80105b67 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80105aa1:	83 ec 04             	sub    $0x4,%esp
80105aa4:	68 80 00 00 00       	push   $0x80
80105aa9:	6a 00                	push   $0x0
80105aab:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105ab1:	50                   	push   %eax
80105ab2:	e8 ca ef ff ff       	call   80104a81 <memset>
80105ab7:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80105aba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80105ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ac4:	83 f8 1f             	cmp    $0x1f,%eax
80105ac7:	76 0a                	jbe    80105ad3 <sys_exec+0x72>
      return -1;
80105ac9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ace:	e9 94 00 00 00       	jmp    80105b67 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad6:	c1 e0 02             	shl    $0x2,%eax
80105ad9:	89 c2                	mov    %eax,%edx
80105adb:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105ae1:	01 c2                	add    %eax,%edx
80105ae3:	83 ec 08             	sub    $0x8,%esp
80105ae6:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105aec:	50                   	push   %eax
80105aed:	52                   	push   %edx
80105aee:	e8 18 f2 ff ff       	call   80104d0b <fetchint>
80105af3:	83 c4 10             	add    $0x10,%esp
80105af6:	85 c0                	test   %eax,%eax
80105af8:	79 07                	jns    80105b01 <sys_exec+0xa0>
      return -1;
80105afa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aff:	eb 66                	jmp    80105b67 <sys_exec+0x106>
    if(uarg == 0){
80105b01:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b07:	85 c0                	test   %eax,%eax
80105b09:	75 27                	jne    80105b32 <sys_exec+0xd1>
      argv[i] = 0;
80105b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105b15:	00 00 00 00 
      break;
80105b19:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b1d:	83 ec 08             	sub    $0x8,%esp
80105b20:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105b26:	52                   	push   %edx
80105b27:	50                   	push   %eax
80105b28:	e8 75 b0 ff ff       	call   80100ba2 <exec>
80105b2d:	83 c4 10             	add    $0x10,%esp
80105b30:	eb 35                	jmp    80105b67 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105b32:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105b38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b3b:	c1 e2 02             	shl    $0x2,%edx
80105b3e:	01 c2                	add    %eax,%edx
80105b40:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105b46:	83 ec 08             	sub    $0x8,%esp
80105b49:	52                   	push   %edx
80105b4a:	50                   	push   %eax
80105b4b:	e8 ea f1 ff ff       	call   80104d3a <fetchstr>
80105b50:	83 c4 10             	add    $0x10,%esp
80105b53:	85 c0                	test   %eax,%eax
80105b55:	79 07                	jns    80105b5e <sys_exec+0xfd>
      return -1;
80105b57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5c:	eb 09                	jmp    80105b67 <sys_exec+0x106>
  for(i=0;; i++){
80105b5e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105b62:	e9 5a ff ff ff       	jmp    80105ac1 <sys_exec+0x60>
}
80105b67:	c9                   	leave
80105b68:	c3                   	ret

80105b69 <sys_pipe>:

int
sys_pipe(void)
{
80105b69:	55                   	push   %ebp
80105b6a:	89 e5                	mov    %esp,%ebp
80105b6c:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105b6f:	83 ec 04             	sub    $0x4,%esp
80105b72:	6a 08                	push   $0x8
80105b74:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105b77:	50                   	push   %eax
80105b78:	6a 00                	push   $0x0
80105b7a:	e8 3e f2 ff ff       	call   80104dbd <argptr>
80105b7f:	83 c4 10             	add    $0x10,%esp
80105b82:	85 c0                	test   %eax,%eax
80105b84:	79 0a                	jns    80105b90 <sys_pipe+0x27>
    return -1;
80105b86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b8b:	e9 ae 00 00 00       	jmp    80105c3e <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105b90:	83 ec 08             	sub    $0x8,%esp
80105b93:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b96:	50                   	push   %eax
80105b97:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105b9a:	50                   	push   %eax
80105b9b:	e8 cd d9 ff ff       	call   8010356d <pipealloc>
80105ba0:	83 c4 10             	add    $0x10,%esp
80105ba3:	85 c0                	test   %eax,%eax
80105ba5:	79 0a                	jns    80105bb1 <sys_pipe+0x48>
    return -1;
80105ba7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bac:	e9 8d 00 00 00       	jmp    80105c3e <sys_pipe+0xd5>
  fd0 = -1;
80105bb1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105bbb:	83 ec 0c             	sub    $0xc,%esp
80105bbe:	50                   	push   %eax
80105bbf:	e8 7b f3 ff ff       	call   80104f3f <fdalloc>
80105bc4:	83 c4 10             	add    $0x10,%esp
80105bc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bce:	78 18                	js     80105be8 <sys_pipe+0x7f>
80105bd0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105bd3:	83 ec 0c             	sub    $0xc,%esp
80105bd6:	50                   	push   %eax
80105bd7:	e8 63 f3 ff ff       	call   80104f3f <fdalloc>
80105bdc:	83 c4 10             	add    $0x10,%esp
80105bdf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105be2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105be6:	79 3e                	jns    80105c26 <sys_pipe+0xbd>
    if(fd0 >= 0)
80105be8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105bec:	78 13                	js     80105c01 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105bee:	e8 3d de ff ff       	call   80103a30 <myproc>
80105bf3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bf6:	83 c2 08             	add    $0x8,%edx
80105bf9:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105c00:	00 
    fileclose(rf);
80105c01:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105c04:	83 ec 0c             	sub    $0xc,%esp
80105c07:	50                   	push   %eax
80105c08:	e8 98 b4 ff ff       	call   801010a5 <fileclose>
80105c0d:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105c10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105c13:	83 ec 0c             	sub    $0xc,%esp
80105c16:	50                   	push   %eax
80105c17:	e8 89 b4 ff ff       	call   801010a5 <fileclose>
80105c1c:	83 c4 10             	add    $0x10,%esp
    return -1;
80105c1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c24:	eb 18                	jmp    80105c3e <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c2c:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105c31:	8d 50 04             	lea    0x4(%eax),%edx
80105c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c37:	89 02                	mov    %eax,(%edx)
  return 0;
80105c39:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c3e:	c9                   	leave
80105c3f:	c3                   	ret

80105c40 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105c40:	55                   	push   %ebp
80105c41:	89 e5                	mov    %esp,%ebp
80105c43:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105c46:	e8 e4 e0 ff ff       	call   80103d2f <fork>
}
80105c4b:	c9                   	leave
80105c4c:	c3                   	ret

80105c4d <sys_exit>:

int
sys_exit(void)
{
80105c4d:	55                   	push   %ebp
80105c4e:	89 e5                	mov    %esp,%ebp
80105c50:	83 ec 08             	sub    $0x8,%esp
  exit();
80105c53:	e8 50 e2 ff ff       	call   80103ea8 <exit>
  return 0;  // not reached
80105c58:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c5d:	c9                   	leave
80105c5e:	c3                   	ret

80105c5f <sys_wait>:

int
sys_wait(void)
{
80105c5f:	55                   	push   %ebp
80105c60:	89 e5                	mov    %esp,%ebp
80105c62:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105c65:	e8 5e e3 ff ff       	call   80103fc8 <wait>
}
80105c6a:	c9                   	leave
80105c6b:	c3                   	ret

80105c6c <sys_kill>:

int
sys_kill(void)
{
80105c6c:	55                   	push   %ebp
80105c6d:	89 e5                	mov    %esp,%ebp
80105c6f:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105c72:	83 ec 08             	sub    $0x8,%esp
80105c75:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c78:	50                   	push   %eax
80105c79:	6a 00                	push   $0x0
80105c7b:	e8 10 f1 ff ff       	call   80104d90 <argint>
80105c80:	83 c4 10             	add    $0x10,%esp
80105c83:	85 c0                	test   %eax,%eax
80105c85:	79 07                	jns    80105c8e <sys_kill+0x22>
    return -1;
80105c87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8c:	eb 0f                	jmp    80105c9d <sys_kill+0x31>
  return kill(pid);
80105c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c91:	83 ec 0c             	sub    $0xc,%esp
80105c94:	50                   	push   %eax
80105c95:	e8 5d e7 ff ff       	call   801043f7 <kill>
80105c9a:	83 c4 10             	add    $0x10,%esp
}
80105c9d:	c9                   	leave
80105c9e:	c3                   	ret

80105c9f <sys_getpid>:

int
sys_getpid(void)
{
80105c9f:	55                   	push   %ebp
80105ca0:	89 e5                	mov    %esp,%ebp
80105ca2:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105ca5:	e8 86 dd ff ff       	call   80103a30 <myproc>
80105caa:	8b 40 10             	mov    0x10(%eax),%eax
}
80105cad:	c9                   	leave
80105cae:	c3                   	ret

80105caf <sys_sbrk>:

int
sys_sbrk(void)
{
80105caf:	55                   	push   %ebp
80105cb0:	89 e5                	mov    %esp,%ebp
80105cb2:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105cb5:	83 ec 08             	sub    $0x8,%esp
80105cb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105cbb:	50                   	push   %eax
80105cbc:	6a 00                	push   $0x0
80105cbe:	e8 cd f0 ff ff       	call   80104d90 <argint>
80105cc3:	83 c4 10             	add    $0x10,%esp
80105cc6:	85 c0                	test   %eax,%eax
80105cc8:	79 07                	jns    80105cd1 <sys_sbrk+0x22>
    return -1;
80105cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccf:	eb 27                	jmp    80105cf8 <sys_sbrk+0x49>
  addr = myproc()->sz;
80105cd1:	e8 5a dd ff ff       	call   80103a30 <myproc>
80105cd6:	8b 00                	mov    (%eax),%eax
80105cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cde:	83 ec 0c             	sub    $0xc,%esp
80105ce1:	50                   	push   %eax
80105ce2:	e8 ad df ff ff       	call   80103c94 <growproc>
80105ce7:	83 c4 10             	add    $0x10,%esp
80105cea:	85 c0                	test   %eax,%eax
80105cec:	79 07                	jns    80105cf5 <sys_sbrk+0x46>
    return -1;
80105cee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cf3:	eb 03                	jmp    80105cf8 <sys_sbrk+0x49>
  return addr;
80105cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105cf8:	c9                   	leave
80105cf9:	c3                   	ret

80105cfa <sys_sleep>:

int
sys_sleep(void)
{
80105cfa:	55                   	push   %ebp
80105cfb:	89 e5                	mov    %esp,%ebp
80105cfd:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d00:	83 ec 08             	sub    $0x8,%esp
80105d03:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d06:	50                   	push   %eax
80105d07:	6a 00                	push   $0x0
80105d09:	e8 82 f0 ff ff       	call   80104d90 <argint>
80105d0e:	83 c4 10             	add    $0x10,%esp
80105d11:	85 c0                	test   %eax,%eax
80105d13:	79 07                	jns    80105d1c <sys_sleep+0x22>
    return -1;
80105d15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1a:	eb 76                	jmp    80105d92 <sys_sleep+0x98>
  acquire(&tickslock);
80105d1c:	83 ec 0c             	sub    $0xc,%esp
80105d1f:	68 40 69 19 80       	push   $0x80196940
80105d24:	e8 e2 ea ff ff       	call   8010480b <acquire>
80105d29:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105d2c:	a1 74 69 19 80       	mov    0x80196974,%eax
80105d31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105d34:	eb 38                	jmp    80105d6e <sys_sleep+0x74>
    if(myproc()->killed){
80105d36:	e8 f5 dc ff ff       	call   80103a30 <myproc>
80105d3b:	8b 40 24             	mov    0x24(%eax),%eax
80105d3e:	85 c0                	test   %eax,%eax
80105d40:	74 17                	je     80105d59 <sys_sleep+0x5f>
      release(&tickslock);
80105d42:	83 ec 0c             	sub    $0xc,%esp
80105d45:	68 40 69 19 80       	push   $0x80196940
80105d4a:	e8 2a eb ff ff       	call   80104879 <release>
80105d4f:	83 c4 10             	add    $0x10,%esp
      return -1;
80105d52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d57:	eb 39                	jmp    80105d92 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105d59:	83 ec 08             	sub    $0x8,%esp
80105d5c:	68 40 69 19 80       	push   $0x80196940
80105d61:	68 74 69 19 80       	push   $0x80196974
80105d66:	e8 6e e5 ff ff       	call   801042d9 <sleep>
80105d6b:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105d6e:	a1 74 69 19 80       	mov    0x80196974,%eax
80105d73:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105d76:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d79:	39 d0                	cmp    %edx,%eax
80105d7b:	72 b9                	jb     80105d36 <sys_sleep+0x3c>
  }
  release(&tickslock);
80105d7d:	83 ec 0c             	sub    $0xc,%esp
80105d80:	68 40 69 19 80       	push   $0x80196940
80105d85:	e8 ef ea ff ff       	call   80104879 <release>
80105d8a:	83 c4 10             	add    $0x10,%esp
  return 0;
80105d8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d92:	c9                   	leave
80105d93:	c3                   	ret

80105d94 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105d94:	55                   	push   %ebp
80105d95:	89 e5                	mov    %esp,%ebp
80105d97:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105d9a:	83 ec 0c             	sub    $0xc,%esp
80105d9d:	68 40 69 19 80       	push   $0x80196940
80105da2:	e8 64 ea ff ff       	call   8010480b <acquire>
80105da7:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105daa:	a1 74 69 19 80       	mov    0x80196974,%eax
80105daf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105db2:	83 ec 0c             	sub    $0xc,%esp
80105db5:	68 40 69 19 80       	push   $0x80196940
80105dba:	e8 ba ea ff ff       	call   80104879 <release>
80105dbf:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105dc5:	c9                   	leave
80105dc6:	c3                   	ret

80105dc7 <sys_printpt>:

//추가
int
sys_printpt(void){
80105dc7:	55                   	push   %ebp
80105dc8:	89 e5                	mov    %esp,%ebp
80105dca:	83 ec 18             	sub    $0x18,%esp
  int pid;
  if (argint(0, &pid) < 0){
80105dcd:	83 ec 08             	sub    $0x8,%esp
80105dd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105dd3:	50                   	push   %eax
80105dd4:	6a 00                	push   $0x0
80105dd6:	e8 b5 ef ff ff       	call   80104d90 <argint>
80105ddb:	83 c4 10             	add    $0x10,%esp
80105dde:	85 c0                	test   %eax,%eax
80105de0:	79 07                	jns    80105de9 <sys_printpt+0x22>
    return -1;
80105de2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105de7:	eb 14                	jmp    80105dfd <sys_printpt+0x36>
  }
  printpt(pid);
80105de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dec:	83 ec 0c             	sub    $0xc,%esp
80105def:	50                   	push   %eax
80105df0:	e8 80 e7 ff ff       	call   80104575 <printpt>
80105df5:	83 c4 10             	add    $0x10,%esp
  return 0;
80105df8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dfd:	c9                   	leave
80105dfe:	c3                   	ret

80105dff <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105dff:	1e                   	push   %ds
  pushl %es
80105e00:	06                   	push   %es
  pushl %fs
80105e01:	0f a0                	push   %fs
  pushl %gs
80105e03:	0f a8                	push   %gs
  pushal
80105e05:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105e06:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105e0a:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105e0c:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105e0e:	54                   	push   %esp
  call trap
80105e0f:	e8 e3 01 00 00       	call   80105ff7 <trap>
  addl $4, %esp
80105e14:	83 c4 04             	add    $0x4,%esp

80105e17 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105e17:	61                   	popa
  popl %gs
80105e18:	0f a9                	pop    %gs
  popl %fs
80105e1a:	0f a1                	pop    %fs
  popl %es
80105e1c:	07                   	pop    %es
  popl %ds
80105e1d:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105e1e:	83 c4 08             	add    $0x8,%esp
  iret
80105e21:	cf                   	iret

80105e22 <lidt>:
{
80105e22:	55                   	push   %ebp
80105e23:	89 e5                	mov    %esp,%ebp
80105e25:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e2b:	83 e8 01             	sub    $0x1,%eax
80105e2e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105e32:	8b 45 08             	mov    0x8(%ebp),%eax
80105e35:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105e39:	8b 45 08             	mov    0x8(%ebp),%eax
80105e3c:	c1 e8 10             	shr    $0x10,%eax
80105e3f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105e43:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105e46:	0f 01 18             	lidtl  (%eax)
}
80105e49:	90                   	nop
80105e4a:	c9                   	leave
80105e4b:	c3                   	ret

80105e4c <rcr2>:

static inline uint
rcr2(void)
{
80105e4c:	55                   	push   %ebp
80105e4d:	89 e5                	mov    %esp,%ebp
80105e4f:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105e52:	0f 20 d0             	mov    %cr2,%eax
80105e55:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105e58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e5b:	c9                   	leave
80105e5c:	c3                   	ret

80105e5d <lcr3>:

static inline void
lcr3(uint val)
{
80105e5d:	55                   	push   %ebp
80105e5e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105e60:	8b 45 08             	mov    0x8(%ebp),%eax
80105e63:	0f 22 d8             	mov    %eax,%cr3
}
80105e66:	90                   	nop
80105e67:	5d                   	pop    %ebp
80105e68:	c3                   	ret

80105e69 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105e69:	55                   	push   %ebp
80105e6a:	89 e5                	mov    %esp,%ebp
80105e6c:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105e6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105e76:	e9 c3 00 00 00       	jmp    80105f3e <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7e:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105e85:	89 c2                	mov    %eax,%edx
80105e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8a:	66 89 14 c5 40 61 19 	mov    %dx,-0x7fe69ec0(,%eax,8)
80105e91:	80 
80105e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e95:	66 c7 04 c5 42 61 19 	movw   $0x8,-0x7fe69ebe(,%eax,8)
80105e9c:	80 08 00 
80105e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea2:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105ea9:	80 
80105eaa:	83 e2 e0             	and    $0xffffffe0,%edx
80105ead:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105eb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb7:	0f b6 14 c5 44 61 19 	movzbl -0x7fe69ebc(,%eax,8),%edx
80105ebe:	80 
80105ebf:	83 e2 1f             	and    $0x1f,%edx
80105ec2:	88 14 c5 44 61 19 80 	mov    %dl,-0x7fe69ebc(,%eax,8)
80105ec9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ecc:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105ed3:	80 
80105ed4:	83 e2 f0             	and    $0xfffffff0,%edx
80105ed7:	83 ca 0e             	or     $0xe,%edx
80105eda:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee4:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105eeb:	80 
80105eec:	83 e2 ef             	and    $0xffffffef,%edx
80105eef:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef9:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f00:	80 
80105f01:	83 e2 9f             	and    $0xffffff9f,%edx
80105f04:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f0e:	0f b6 14 c5 45 61 19 	movzbl -0x7fe69ebb(,%eax,8),%edx
80105f15:	80 
80105f16:	83 ca 80             	or     $0xffffff80,%edx
80105f19:	88 14 c5 45 61 19 80 	mov    %dl,-0x7fe69ebb(,%eax,8)
80105f20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f23:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105f2a:	c1 e8 10             	shr    $0x10,%eax
80105f2d:	89 c2                	mov    %eax,%edx
80105f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f32:	66 89 14 c5 46 61 19 	mov    %dx,-0x7fe69eba(,%eax,8)
80105f39:	80 
  for(i = 0; i < 256; i++)
80105f3a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105f3e:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105f45:	0f 8e 30 ff ff ff    	jle    80105e7b <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105f4b:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105f50:	66 a3 40 63 19 80    	mov    %ax,0x80196340
80105f56:	66 c7 05 42 63 19 80 	movw   $0x8,0x80196342
80105f5d:	08 00 
80105f5f:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105f66:	83 e0 e0             	and    $0xffffffe0,%eax
80105f69:	a2 44 63 19 80       	mov    %al,0x80196344
80105f6e:	0f b6 05 44 63 19 80 	movzbl 0x80196344,%eax
80105f75:	83 e0 1f             	and    $0x1f,%eax
80105f78:	a2 44 63 19 80       	mov    %al,0x80196344
80105f7d:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105f84:	83 c8 0f             	or     $0xf,%eax
80105f87:	a2 45 63 19 80       	mov    %al,0x80196345
80105f8c:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105f93:	83 e0 ef             	and    $0xffffffef,%eax
80105f96:	a2 45 63 19 80       	mov    %al,0x80196345
80105f9b:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fa2:	83 c8 60             	or     $0x60,%eax
80105fa5:	a2 45 63 19 80       	mov    %al,0x80196345
80105faa:	0f b6 05 45 63 19 80 	movzbl 0x80196345,%eax
80105fb1:	83 c8 80             	or     $0xffffff80,%eax
80105fb4:	a2 45 63 19 80       	mov    %al,0x80196345
80105fb9:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105fbe:	c1 e8 10             	shr    $0x10,%eax
80105fc1:	66 a3 46 63 19 80    	mov    %ax,0x80196346

  initlock(&tickslock, "time");
80105fc7:	83 ec 08             	sub    $0x8,%esp
80105fca:	68 cc a5 10 80       	push   $0x8010a5cc
80105fcf:	68 40 69 19 80       	push   $0x80196940
80105fd4:	e8 10 e8 ff ff       	call   801047e9 <initlock>
80105fd9:	83 c4 10             	add    $0x10,%esp
}
80105fdc:	90                   	nop
80105fdd:	c9                   	leave
80105fde:	c3                   	ret

80105fdf <idtinit>:

void
idtinit(void)
{
80105fdf:	55                   	push   %ebp
80105fe0:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105fe2:	68 00 08 00 00       	push   $0x800
80105fe7:	68 40 61 19 80       	push   $0x80196140
80105fec:	e8 31 fe ff ff       	call   80105e22 <lidt>
80105ff1:	83 c4 08             	add    $0x8,%esp
}
80105ff4:	90                   	nop
80105ff5:	c9                   	leave
80105ff6:	c3                   	ret

80105ff7 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105ff7:	55                   	push   %ebp
80105ff8:	89 e5                	mov    %esp,%ebp
80105ffa:	57                   	push   %edi
80105ffb:	56                   	push   %esi
80105ffc:	53                   	push   %ebx
80105ffd:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80106000:	8b 45 08             	mov    0x8(%ebp),%eax
80106003:	8b 40 30             	mov    0x30(%eax),%eax
80106006:	83 f8 40             	cmp    $0x40,%eax
80106009:	75 3b                	jne    80106046 <trap+0x4f>
    if(myproc()->killed)
8010600b:	e8 20 da ff ff       	call   80103a30 <myproc>
80106010:	8b 40 24             	mov    0x24(%eax),%eax
80106013:	85 c0                	test   %eax,%eax
80106015:	74 05                	je     8010601c <trap+0x25>
      exit();
80106017:	e8 8c de ff ff       	call   80103ea8 <exit>
    myproc()->tf = tf;
8010601c:	e8 0f da ff ff       	call   80103a30 <myproc>
80106021:	8b 55 08             	mov    0x8(%ebp),%edx
80106024:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106027:	e8 21 ee ff ff       	call   80104e4d <syscall>
    if(myproc()->killed)
8010602c:	e8 ff d9 ff ff       	call   80103a30 <myproc>
80106031:	8b 40 24             	mov    0x24(%eax),%eax
80106034:	85 c0                	test   %eax,%eax
80106036:	0f 84 a1 02 00 00    	je     801062dd <trap+0x2e6>
      exit();
8010603c:	e8 67 de ff ff       	call   80103ea8 <exit>
    return;
80106041:	e9 97 02 00 00       	jmp    801062dd <trap+0x2e6>
  }

  switch(tf->trapno){
80106046:	8b 45 08             	mov    0x8(%ebp),%eax
80106049:	8b 40 30             	mov    0x30(%eax),%eax
8010604c:	83 e8 0e             	sub    $0xe,%eax
8010604f:	83 f8 31             	cmp    $0x31,%eax
80106052:	0f 87 50 01 00 00    	ja     801061a8 <trap+0x1b1>
80106058:	8b 04 85 8c a6 10 80 	mov    -0x7fef5974(,%eax,4),%eax
8010605f:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106061:	e8 37 d9 ff ff       	call   8010399d <cpuid>
80106066:	85 c0                	test   %eax,%eax
80106068:	75 3d                	jne    801060a7 <trap+0xb0>
      acquire(&tickslock);
8010606a:	83 ec 0c             	sub    $0xc,%esp
8010606d:	68 40 69 19 80       	push   $0x80196940
80106072:	e8 94 e7 ff ff       	call   8010480b <acquire>
80106077:	83 c4 10             	add    $0x10,%esp
      ticks++;
8010607a:	a1 74 69 19 80       	mov    0x80196974,%eax
8010607f:	83 c0 01             	add    $0x1,%eax
80106082:	a3 74 69 19 80       	mov    %eax,0x80196974
      wakeup(&ticks);
80106087:	83 ec 0c             	sub    $0xc,%esp
8010608a:	68 74 69 19 80       	push   $0x80196974
8010608f:	e8 2c e3 ff ff       	call   801043c0 <wakeup>
80106094:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106097:	83 ec 0c             	sub    $0xc,%esp
8010609a:	68 40 69 19 80       	push   $0x80196940
8010609f:	e8 d5 e7 ff ff       	call   80104879 <release>
801060a4:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
801060a7:	e8 72 ca ff ff       	call   80102b1e <lapiceoi>
    break;
801060ac:	e9 ac 01 00 00       	jmp    8010625d <trap+0x266>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801060b1:	e8 52 3f 00 00       	call   8010a008 <ideintr>
    lapiceoi();
801060b6:	e8 63 ca ff ff       	call   80102b1e <lapiceoi>
    break;
801060bb:	e9 9d 01 00 00       	jmp    8010625d <trap+0x266>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801060c0:	e8 a4 c8 ff ff       	call   80102969 <kbdintr>
    lapiceoi();
801060c5:	e8 54 ca ff ff       	call   80102b1e <lapiceoi>
    break;
801060ca:	e9 8e 01 00 00       	jmp    8010625d <trap+0x266>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801060cf:	e8 dd 03 00 00       	call   801064b1 <uartintr>
    lapiceoi();
801060d4:	e8 45 ca ff ff       	call   80102b1e <lapiceoi>
    break;
801060d9:	e9 7f 01 00 00       	jmp    8010625d <trap+0x266>
  case T_IRQ0 + 0xB:
    i8254_intr();
801060de:	e8 ee 2b 00 00       	call   80108cd1 <i8254_intr>
    lapiceoi();
801060e3:	e8 36 ca ff ff       	call   80102b1e <lapiceoi>
    break;
801060e8:	e9 70 01 00 00       	jmp    8010625d <trap+0x266>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060ed:	8b 45 08             	mov    0x8(%ebp),%eax
801060f0:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801060f3:	8b 45 08             	mov    0x8(%ebp),%eax
801060f6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801060fa:	0f b7 d8             	movzwl %ax,%ebx
801060fd:	e8 9b d8 ff ff       	call   8010399d <cpuid>
80106102:	56                   	push   %esi
80106103:	53                   	push   %ebx
80106104:	50                   	push   %eax
80106105:	68 d4 a5 10 80       	push   $0x8010a5d4
8010610a:	e8 e5 a2 ff ff       	call   801003f4 <cprintf>
8010610f:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106112:	e8 07 ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106117:	e9 41 01 00 00       	jmp    8010625d <trap+0x266>
  //추가
  case T_PGFLT:
		uint va = PGROUNDDOWN(rcr2()); 
8010611c:	e8 2b fd ff ff       	call   80105e4c <rcr2>
80106121:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106126:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		char* mem=kalloc();
80106129:	e8 7a c6 ff ff       	call   801027a8 <kalloc>
8010612e:	89 45 e0             	mov    %eax,-0x20(%ebp)
		if(mem==0){
80106131:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80106135:	75 15                	jne    8010614c <trap+0x155>
			cprintf("allocuvm out of memory\n");
80106137:	83 ec 0c             	sub    $0xc,%esp
8010613a:	68 f8 a5 10 80       	push   $0x8010a5f8
8010613f:	e8 b0 a2 ff ff       	call   801003f4 <cprintf>
80106144:	83 c4 10             	add    $0x10,%esp
			break;
80106147:	e9 11 01 00 00       	jmp    8010625d <trap+0x266>
		}	
		memset(mem,0,PGSIZE);
8010614c:	83 ec 04             	sub    $0x4,%esp
8010614f:	68 00 10 00 00       	push   $0x1000
80106154:	6a 00                	push   $0x0
80106156:	ff 75 e0             	push   -0x20(%ebp)
80106159:	e8 23 e9 ff ff       	call   80104a81 <memset>
8010615e:	83 c4 10             	add    $0x10,%esp
		mappages(myproc()->pgdir,(char*)va,PGSIZE,V2P(mem),PTE_W|PTE_U|PTE_P);
80106161:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106164:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
8010616a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010616d:	e8 be d8 ff ff       	call   80103a30 <myproc>
80106172:	8b 40 04             	mov    0x4(%eax),%eax
80106175:	83 ec 0c             	sub    $0xc,%esp
80106178:	6a 07                	push   $0x7
8010617a:	56                   	push   %esi
8010617b:	68 00 10 00 00       	push   $0x1000
80106180:	53                   	push   %ebx
80106181:	50                   	push   %eax
80106182:	e8 ee 11 00 00       	call   80107375 <mappages>
80106187:	83 c4 20             	add    $0x20,%esp

		lcr3(V2P(myproc()->pgdir));
8010618a:	e8 a1 d8 ff ff       	call   80103a30 <myproc>
8010618f:	8b 40 04             	mov    0x4(%eax),%eax
80106192:	05 00 00 00 80       	add    $0x80000000,%eax
80106197:	83 ec 0c             	sub    $0xc,%esp
8010619a:	50                   	push   %eax
8010619b:	e8 bd fc ff ff       	call   80105e5d <lcr3>
801061a0:	83 c4 10             	add    $0x10,%esp

		break;
801061a3:	e9 b5 00 00 00       	jmp    8010625d <trap+0x266>
    
  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801061a8:	e8 83 d8 ff ff       	call   80103a30 <myproc>
801061ad:	85 c0                	test   %eax,%eax
801061af:	74 11                	je     801061c2 <trap+0x1cb>
801061b1:	8b 45 08             	mov    0x8(%ebp),%eax
801061b4:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061b8:	0f b7 c0             	movzwl %ax,%eax
801061bb:	83 e0 03             	and    $0x3,%eax
801061be:	85 c0                	test   %eax,%eax
801061c0:	75 39                	jne    801061fb <trap+0x204>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801061c2:	e8 85 fc ff ff       	call   80105e4c <rcr2>
801061c7:	89 c3                	mov    %eax,%ebx
801061c9:	8b 45 08             	mov    0x8(%ebp),%eax
801061cc:	8b 70 38             	mov    0x38(%eax),%esi
801061cf:	e8 c9 d7 ff ff       	call   8010399d <cpuid>
801061d4:	8b 55 08             	mov    0x8(%ebp),%edx
801061d7:	8b 52 30             	mov    0x30(%edx),%edx
801061da:	83 ec 0c             	sub    $0xc,%esp
801061dd:	53                   	push   %ebx
801061de:	56                   	push   %esi
801061df:	50                   	push   %eax
801061e0:	52                   	push   %edx
801061e1:	68 10 a6 10 80       	push   $0x8010a610
801061e6:	e8 09 a2 ff ff       	call   801003f4 <cprintf>
801061eb:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801061ee:	83 ec 0c             	sub    $0xc,%esp
801061f1:	68 42 a6 10 80       	push   $0x8010a642
801061f6:	e8 c6 a3 ff ff       	call   801005c1 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801061fb:	e8 4c fc ff ff       	call   80105e4c <rcr2>
80106200:	89 c6                	mov    %eax,%esi
80106202:	8b 45 08             	mov    0x8(%ebp),%eax
80106205:	8b 40 38             	mov    0x38(%eax),%eax
80106208:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010620b:	e8 8d d7 ff ff       	call   8010399d <cpuid>
80106210:	89 c3                	mov    %eax,%ebx
80106212:	8b 45 08             	mov    0x8(%ebp),%eax
80106215:	8b 48 34             	mov    0x34(%eax),%ecx
80106218:	89 4d d0             	mov    %ecx,-0x30(%ebp)
8010621b:	8b 45 08             	mov    0x8(%ebp),%eax
8010621e:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106221:	e8 0a d8 ff ff       	call   80103a30 <myproc>
80106226:	8d 50 6c             	lea    0x6c(%eax),%edx
80106229:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010622c:	e8 ff d7 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106231:	8b 40 10             	mov    0x10(%eax),%eax
80106234:	56                   	push   %esi
80106235:	ff 75 d4             	push   -0x2c(%ebp)
80106238:	53                   	push   %ebx
80106239:	ff 75 d0             	push   -0x30(%ebp)
8010623c:	57                   	push   %edi
8010623d:	ff 75 cc             	push   -0x34(%ebp)
80106240:	50                   	push   %eax
80106241:	68 48 a6 10 80       	push   $0x8010a648
80106246:	e8 a9 a1 ff ff       	call   801003f4 <cprintf>
8010624b:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010624e:	e8 dd d7 ff ff       	call   80103a30 <myproc>
80106253:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010625a:	eb 01                	jmp    8010625d <trap+0x266>
    break;
8010625c:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010625d:	e8 ce d7 ff ff       	call   80103a30 <myproc>
80106262:	85 c0                	test   %eax,%eax
80106264:	74 23                	je     80106289 <trap+0x292>
80106266:	e8 c5 d7 ff ff       	call   80103a30 <myproc>
8010626b:	8b 40 24             	mov    0x24(%eax),%eax
8010626e:	85 c0                	test   %eax,%eax
80106270:	74 17                	je     80106289 <trap+0x292>
80106272:	8b 45 08             	mov    0x8(%ebp),%eax
80106275:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106279:	0f b7 c0             	movzwl %ax,%eax
8010627c:	83 e0 03             	and    $0x3,%eax
8010627f:	83 f8 03             	cmp    $0x3,%eax
80106282:	75 05                	jne    80106289 <trap+0x292>
    exit();
80106284:	e8 1f dc ff ff       	call   80103ea8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106289:	e8 a2 d7 ff ff       	call   80103a30 <myproc>
8010628e:	85 c0                	test   %eax,%eax
80106290:	74 1d                	je     801062af <trap+0x2b8>
80106292:	e8 99 d7 ff ff       	call   80103a30 <myproc>
80106297:	8b 40 0c             	mov    0xc(%eax),%eax
8010629a:	83 f8 04             	cmp    $0x4,%eax
8010629d:	75 10                	jne    801062af <trap+0x2b8>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010629f:	8b 45 08             	mov    0x8(%ebp),%eax
801062a2:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
801062a5:	83 f8 20             	cmp    $0x20,%eax
801062a8:	75 05                	jne    801062af <trap+0x2b8>
    yield();
801062aa:	e8 aa df ff ff       	call   80104259 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801062af:	e8 7c d7 ff ff       	call   80103a30 <myproc>
801062b4:	85 c0                	test   %eax,%eax
801062b6:	74 26                	je     801062de <trap+0x2e7>
801062b8:	e8 73 d7 ff ff       	call   80103a30 <myproc>
801062bd:	8b 40 24             	mov    0x24(%eax),%eax
801062c0:	85 c0                	test   %eax,%eax
801062c2:	74 1a                	je     801062de <trap+0x2e7>
801062c4:	8b 45 08             	mov    0x8(%ebp),%eax
801062c7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801062cb:	0f b7 c0             	movzwl %ax,%eax
801062ce:	83 e0 03             	and    $0x3,%eax
801062d1:	83 f8 03             	cmp    $0x3,%eax
801062d4:	75 08                	jne    801062de <trap+0x2e7>
    exit();
801062d6:	e8 cd db ff ff       	call   80103ea8 <exit>
801062db:	eb 01                	jmp    801062de <trap+0x2e7>
    return;
801062dd:	90                   	nop
}
801062de:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062e1:	5b                   	pop    %ebx
801062e2:	5e                   	pop    %esi
801062e3:	5f                   	pop    %edi
801062e4:	5d                   	pop    %ebp
801062e5:	c3                   	ret

801062e6 <inb>:
{
801062e6:	55                   	push   %ebp
801062e7:	89 e5                	mov    %esp,%ebp
801062e9:	83 ec 14             	sub    $0x14,%esp
801062ec:	8b 45 08             	mov    0x8(%ebp),%eax
801062ef:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801062f3:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801062f7:	89 c2                	mov    %eax,%edx
801062f9:	ec                   	in     (%dx),%al
801062fa:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801062fd:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106301:	c9                   	leave
80106302:	c3                   	ret

80106303 <outb>:
{
80106303:	55                   	push   %ebp
80106304:	89 e5                	mov    %esp,%ebp
80106306:	83 ec 08             	sub    $0x8,%esp
80106309:	8b 55 08             	mov    0x8(%ebp),%edx
8010630c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010630f:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106313:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106316:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010631a:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010631e:	ee                   	out    %al,(%dx)
}
8010631f:	90                   	nop
80106320:	c9                   	leave
80106321:	c3                   	ret

80106322 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106322:	55                   	push   %ebp
80106323:	89 e5                	mov    %esp,%ebp
80106325:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106328:	6a 00                	push   $0x0
8010632a:	68 fa 03 00 00       	push   $0x3fa
8010632f:	e8 cf ff ff ff       	call   80106303 <outb>
80106334:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106337:	68 80 00 00 00       	push   $0x80
8010633c:	68 fb 03 00 00       	push   $0x3fb
80106341:	e8 bd ff ff ff       	call   80106303 <outb>
80106346:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106349:	6a 0c                	push   $0xc
8010634b:	68 f8 03 00 00       	push   $0x3f8
80106350:	e8 ae ff ff ff       	call   80106303 <outb>
80106355:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106358:	6a 00                	push   $0x0
8010635a:	68 f9 03 00 00       	push   $0x3f9
8010635f:	e8 9f ff ff ff       	call   80106303 <outb>
80106364:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106367:	6a 03                	push   $0x3
80106369:	68 fb 03 00 00       	push   $0x3fb
8010636e:	e8 90 ff ff ff       	call   80106303 <outb>
80106373:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106376:	6a 00                	push   $0x0
80106378:	68 fc 03 00 00       	push   $0x3fc
8010637d:	e8 81 ff ff ff       	call   80106303 <outb>
80106382:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106385:	6a 01                	push   $0x1
80106387:	68 f9 03 00 00       	push   $0x3f9
8010638c:	e8 72 ff ff ff       	call   80106303 <outb>
80106391:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106394:	68 fd 03 00 00       	push   $0x3fd
80106399:	e8 48 ff ff ff       	call   801062e6 <inb>
8010639e:	83 c4 04             	add    $0x4,%esp
801063a1:	3c ff                	cmp    $0xff,%al
801063a3:	74 61                	je     80106406 <uartinit+0xe4>
    return;
  uart = 1;
801063a5:	c7 05 78 69 19 80 01 	movl   $0x1,0x80196978
801063ac:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801063af:	68 fa 03 00 00       	push   $0x3fa
801063b4:	e8 2d ff ff ff       	call   801062e6 <inb>
801063b9:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801063bc:	68 f8 03 00 00       	push   $0x3f8
801063c1:	e8 20 ff ff ff       	call   801062e6 <inb>
801063c6:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801063c9:	83 ec 08             	sub    $0x8,%esp
801063cc:	6a 00                	push   $0x0
801063ce:	6a 04                	push   $0x4
801063d0:	e8 61 c2 ff ff       	call   80102636 <ioapicenable>
801063d5:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801063d8:	c7 45 f4 54 a7 10 80 	movl   $0x8010a754,-0xc(%ebp)
801063df:	eb 19                	jmp    801063fa <uartinit+0xd8>
    uartputc(*p);
801063e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e4:	0f b6 00             	movzbl (%eax),%eax
801063e7:	0f be c0             	movsbl %al,%eax
801063ea:	83 ec 0c             	sub    $0xc,%esp
801063ed:	50                   	push   %eax
801063ee:	e8 16 00 00 00       	call   80106409 <uartputc>
801063f3:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801063f6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801063fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fd:	0f b6 00             	movzbl (%eax),%eax
80106400:	84 c0                	test   %al,%al
80106402:	75 dd                	jne    801063e1 <uartinit+0xbf>
80106404:	eb 01                	jmp    80106407 <uartinit+0xe5>
    return;
80106406:	90                   	nop
}
80106407:	c9                   	leave
80106408:	c3                   	ret

80106409 <uartputc>:

void
uartputc(int c)
{
80106409:	55                   	push   %ebp
8010640a:	89 e5                	mov    %esp,%ebp
8010640c:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
8010640f:	a1 78 69 19 80       	mov    0x80196978,%eax
80106414:	85 c0                	test   %eax,%eax
80106416:	74 53                	je     8010646b <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106418:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010641f:	eb 11                	jmp    80106432 <uartputc+0x29>
    microdelay(10);
80106421:	83 ec 0c             	sub    $0xc,%esp
80106424:	6a 0a                	push   $0xa
80106426:	e8 0e c7 ff ff       	call   80102b39 <microdelay>
8010642b:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010642e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106432:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106436:	7f 1a                	jg     80106452 <uartputc+0x49>
80106438:	83 ec 0c             	sub    $0xc,%esp
8010643b:	68 fd 03 00 00       	push   $0x3fd
80106440:	e8 a1 fe ff ff       	call   801062e6 <inb>
80106445:	83 c4 10             	add    $0x10,%esp
80106448:	0f b6 c0             	movzbl %al,%eax
8010644b:	83 e0 20             	and    $0x20,%eax
8010644e:	85 c0                	test   %eax,%eax
80106450:	74 cf                	je     80106421 <uartputc+0x18>
  outb(COM1+0, c);
80106452:	8b 45 08             	mov    0x8(%ebp),%eax
80106455:	0f b6 c0             	movzbl %al,%eax
80106458:	83 ec 08             	sub    $0x8,%esp
8010645b:	50                   	push   %eax
8010645c:	68 f8 03 00 00       	push   $0x3f8
80106461:	e8 9d fe ff ff       	call   80106303 <outb>
80106466:	83 c4 10             	add    $0x10,%esp
80106469:	eb 01                	jmp    8010646c <uartputc+0x63>
    return;
8010646b:	90                   	nop
}
8010646c:	c9                   	leave
8010646d:	c3                   	ret

8010646e <uartgetc>:

static int
uartgetc(void)
{
8010646e:	55                   	push   %ebp
8010646f:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106471:	a1 78 69 19 80       	mov    0x80196978,%eax
80106476:	85 c0                	test   %eax,%eax
80106478:	75 07                	jne    80106481 <uartgetc+0x13>
    return -1;
8010647a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010647f:	eb 2e                	jmp    801064af <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106481:	68 fd 03 00 00       	push   $0x3fd
80106486:	e8 5b fe ff ff       	call   801062e6 <inb>
8010648b:	83 c4 04             	add    $0x4,%esp
8010648e:	0f b6 c0             	movzbl %al,%eax
80106491:	83 e0 01             	and    $0x1,%eax
80106494:	85 c0                	test   %eax,%eax
80106496:	75 07                	jne    8010649f <uartgetc+0x31>
    return -1;
80106498:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649d:	eb 10                	jmp    801064af <uartgetc+0x41>
  return inb(COM1+0);
8010649f:	68 f8 03 00 00       	push   $0x3f8
801064a4:	e8 3d fe ff ff       	call   801062e6 <inb>
801064a9:	83 c4 04             	add    $0x4,%esp
801064ac:	0f b6 c0             	movzbl %al,%eax
}
801064af:	c9                   	leave
801064b0:	c3                   	ret

801064b1 <uartintr>:

void
uartintr(void)
{
801064b1:	55                   	push   %ebp
801064b2:	89 e5                	mov    %esp,%ebp
801064b4:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801064b7:	83 ec 0c             	sub    $0xc,%esp
801064ba:	68 6e 64 10 80       	push   $0x8010646e
801064bf:	e8 2a a3 ff ff       	call   801007ee <consoleintr>
801064c4:	83 c4 10             	add    $0x10,%esp
}
801064c7:	90                   	nop
801064c8:	c9                   	leave
801064c9:	c3                   	ret

801064ca <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801064ca:	6a 00                	push   $0x0
  pushl $0
801064cc:	6a 00                	push   $0x0
  jmp alltraps
801064ce:	e9 2c f9 ff ff       	jmp    80105dff <alltraps>

801064d3 <vector1>:
.globl vector1
vector1:
  pushl $0
801064d3:	6a 00                	push   $0x0
  pushl $1
801064d5:	6a 01                	push   $0x1
  jmp alltraps
801064d7:	e9 23 f9 ff ff       	jmp    80105dff <alltraps>

801064dc <vector2>:
.globl vector2
vector2:
  pushl $0
801064dc:	6a 00                	push   $0x0
  pushl $2
801064de:	6a 02                	push   $0x2
  jmp alltraps
801064e0:	e9 1a f9 ff ff       	jmp    80105dff <alltraps>

801064e5 <vector3>:
.globl vector3
vector3:
  pushl $0
801064e5:	6a 00                	push   $0x0
  pushl $3
801064e7:	6a 03                	push   $0x3
  jmp alltraps
801064e9:	e9 11 f9 ff ff       	jmp    80105dff <alltraps>

801064ee <vector4>:
.globl vector4
vector4:
  pushl $0
801064ee:	6a 00                	push   $0x0
  pushl $4
801064f0:	6a 04                	push   $0x4
  jmp alltraps
801064f2:	e9 08 f9 ff ff       	jmp    80105dff <alltraps>

801064f7 <vector5>:
.globl vector5
vector5:
  pushl $0
801064f7:	6a 00                	push   $0x0
  pushl $5
801064f9:	6a 05                	push   $0x5
  jmp alltraps
801064fb:	e9 ff f8 ff ff       	jmp    80105dff <alltraps>

80106500 <vector6>:
.globl vector6
vector6:
  pushl $0
80106500:	6a 00                	push   $0x0
  pushl $6
80106502:	6a 06                	push   $0x6
  jmp alltraps
80106504:	e9 f6 f8 ff ff       	jmp    80105dff <alltraps>

80106509 <vector7>:
.globl vector7
vector7:
  pushl $0
80106509:	6a 00                	push   $0x0
  pushl $7
8010650b:	6a 07                	push   $0x7
  jmp alltraps
8010650d:	e9 ed f8 ff ff       	jmp    80105dff <alltraps>

80106512 <vector8>:
.globl vector8
vector8:
  pushl $8
80106512:	6a 08                	push   $0x8
  jmp alltraps
80106514:	e9 e6 f8 ff ff       	jmp    80105dff <alltraps>

80106519 <vector9>:
.globl vector9
vector9:
  pushl $0
80106519:	6a 00                	push   $0x0
  pushl $9
8010651b:	6a 09                	push   $0x9
  jmp alltraps
8010651d:	e9 dd f8 ff ff       	jmp    80105dff <alltraps>

80106522 <vector10>:
.globl vector10
vector10:
  pushl $10
80106522:	6a 0a                	push   $0xa
  jmp alltraps
80106524:	e9 d6 f8 ff ff       	jmp    80105dff <alltraps>

80106529 <vector11>:
.globl vector11
vector11:
  pushl $11
80106529:	6a 0b                	push   $0xb
  jmp alltraps
8010652b:	e9 cf f8 ff ff       	jmp    80105dff <alltraps>

80106530 <vector12>:
.globl vector12
vector12:
  pushl $12
80106530:	6a 0c                	push   $0xc
  jmp alltraps
80106532:	e9 c8 f8 ff ff       	jmp    80105dff <alltraps>

80106537 <vector13>:
.globl vector13
vector13:
  pushl $13
80106537:	6a 0d                	push   $0xd
  jmp alltraps
80106539:	e9 c1 f8 ff ff       	jmp    80105dff <alltraps>

8010653e <vector14>:
.globl vector14
vector14:
  pushl $14
8010653e:	6a 0e                	push   $0xe
  jmp alltraps
80106540:	e9 ba f8 ff ff       	jmp    80105dff <alltraps>

80106545 <vector15>:
.globl vector15
vector15:
  pushl $0
80106545:	6a 00                	push   $0x0
  pushl $15
80106547:	6a 0f                	push   $0xf
  jmp alltraps
80106549:	e9 b1 f8 ff ff       	jmp    80105dff <alltraps>

8010654e <vector16>:
.globl vector16
vector16:
  pushl $0
8010654e:	6a 00                	push   $0x0
  pushl $16
80106550:	6a 10                	push   $0x10
  jmp alltraps
80106552:	e9 a8 f8 ff ff       	jmp    80105dff <alltraps>

80106557 <vector17>:
.globl vector17
vector17:
  pushl $17
80106557:	6a 11                	push   $0x11
  jmp alltraps
80106559:	e9 a1 f8 ff ff       	jmp    80105dff <alltraps>

8010655e <vector18>:
.globl vector18
vector18:
  pushl $0
8010655e:	6a 00                	push   $0x0
  pushl $18
80106560:	6a 12                	push   $0x12
  jmp alltraps
80106562:	e9 98 f8 ff ff       	jmp    80105dff <alltraps>

80106567 <vector19>:
.globl vector19
vector19:
  pushl $0
80106567:	6a 00                	push   $0x0
  pushl $19
80106569:	6a 13                	push   $0x13
  jmp alltraps
8010656b:	e9 8f f8 ff ff       	jmp    80105dff <alltraps>

80106570 <vector20>:
.globl vector20
vector20:
  pushl $0
80106570:	6a 00                	push   $0x0
  pushl $20
80106572:	6a 14                	push   $0x14
  jmp alltraps
80106574:	e9 86 f8 ff ff       	jmp    80105dff <alltraps>

80106579 <vector21>:
.globl vector21
vector21:
  pushl $0
80106579:	6a 00                	push   $0x0
  pushl $21
8010657b:	6a 15                	push   $0x15
  jmp alltraps
8010657d:	e9 7d f8 ff ff       	jmp    80105dff <alltraps>

80106582 <vector22>:
.globl vector22
vector22:
  pushl $0
80106582:	6a 00                	push   $0x0
  pushl $22
80106584:	6a 16                	push   $0x16
  jmp alltraps
80106586:	e9 74 f8 ff ff       	jmp    80105dff <alltraps>

8010658b <vector23>:
.globl vector23
vector23:
  pushl $0
8010658b:	6a 00                	push   $0x0
  pushl $23
8010658d:	6a 17                	push   $0x17
  jmp alltraps
8010658f:	e9 6b f8 ff ff       	jmp    80105dff <alltraps>

80106594 <vector24>:
.globl vector24
vector24:
  pushl $0
80106594:	6a 00                	push   $0x0
  pushl $24
80106596:	6a 18                	push   $0x18
  jmp alltraps
80106598:	e9 62 f8 ff ff       	jmp    80105dff <alltraps>

8010659d <vector25>:
.globl vector25
vector25:
  pushl $0
8010659d:	6a 00                	push   $0x0
  pushl $25
8010659f:	6a 19                	push   $0x19
  jmp alltraps
801065a1:	e9 59 f8 ff ff       	jmp    80105dff <alltraps>

801065a6 <vector26>:
.globl vector26
vector26:
  pushl $0
801065a6:	6a 00                	push   $0x0
  pushl $26
801065a8:	6a 1a                	push   $0x1a
  jmp alltraps
801065aa:	e9 50 f8 ff ff       	jmp    80105dff <alltraps>

801065af <vector27>:
.globl vector27
vector27:
  pushl $0
801065af:	6a 00                	push   $0x0
  pushl $27
801065b1:	6a 1b                	push   $0x1b
  jmp alltraps
801065b3:	e9 47 f8 ff ff       	jmp    80105dff <alltraps>

801065b8 <vector28>:
.globl vector28
vector28:
  pushl $0
801065b8:	6a 00                	push   $0x0
  pushl $28
801065ba:	6a 1c                	push   $0x1c
  jmp alltraps
801065bc:	e9 3e f8 ff ff       	jmp    80105dff <alltraps>

801065c1 <vector29>:
.globl vector29
vector29:
  pushl $0
801065c1:	6a 00                	push   $0x0
  pushl $29
801065c3:	6a 1d                	push   $0x1d
  jmp alltraps
801065c5:	e9 35 f8 ff ff       	jmp    80105dff <alltraps>

801065ca <vector30>:
.globl vector30
vector30:
  pushl $0
801065ca:	6a 00                	push   $0x0
  pushl $30
801065cc:	6a 1e                	push   $0x1e
  jmp alltraps
801065ce:	e9 2c f8 ff ff       	jmp    80105dff <alltraps>

801065d3 <vector31>:
.globl vector31
vector31:
  pushl $0
801065d3:	6a 00                	push   $0x0
  pushl $31
801065d5:	6a 1f                	push   $0x1f
  jmp alltraps
801065d7:	e9 23 f8 ff ff       	jmp    80105dff <alltraps>

801065dc <vector32>:
.globl vector32
vector32:
  pushl $0
801065dc:	6a 00                	push   $0x0
  pushl $32
801065de:	6a 20                	push   $0x20
  jmp alltraps
801065e0:	e9 1a f8 ff ff       	jmp    80105dff <alltraps>

801065e5 <vector33>:
.globl vector33
vector33:
  pushl $0
801065e5:	6a 00                	push   $0x0
  pushl $33
801065e7:	6a 21                	push   $0x21
  jmp alltraps
801065e9:	e9 11 f8 ff ff       	jmp    80105dff <alltraps>

801065ee <vector34>:
.globl vector34
vector34:
  pushl $0
801065ee:	6a 00                	push   $0x0
  pushl $34
801065f0:	6a 22                	push   $0x22
  jmp alltraps
801065f2:	e9 08 f8 ff ff       	jmp    80105dff <alltraps>

801065f7 <vector35>:
.globl vector35
vector35:
  pushl $0
801065f7:	6a 00                	push   $0x0
  pushl $35
801065f9:	6a 23                	push   $0x23
  jmp alltraps
801065fb:	e9 ff f7 ff ff       	jmp    80105dff <alltraps>

80106600 <vector36>:
.globl vector36
vector36:
  pushl $0
80106600:	6a 00                	push   $0x0
  pushl $36
80106602:	6a 24                	push   $0x24
  jmp alltraps
80106604:	e9 f6 f7 ff ff       	jmp    80105dff <alltraps>

80106609 <vector37>:
.globl vector37
vector37:
  pushl $0
80106609:	6a 00                	push   $0x0
  pushl $37
8010660b:	6a 25                	push   $0x25
  jmp alltraps
8010660d:	e9 ed f7 ff ff       	jmp    80105dff <alltraps>

80106612 <vector38>:
.globl vector38
vector38:
  pushl $0
80106612:	6a 00                	push   $0x0
  pushl $38
80106614:	6a 26                	push   $0x26
  jmp alltraps
80106616:	e9 e4 f7 ff ff       	jmp    80105dff <alltraps>

8010661b <vector39>:
.globl vector39
vector39:
  pushl $0
8010661b:	6a 00                	push   $0x0
  pushl $39
8010661d:	6a 27                	push   $0x27
  jmp alltraps
8010661f:	e9 db f7 ff ff       	jmp    80105dff <alltraps>

80106624 <vector40>:
.globl vector40
vector40:
  pushl $0
80106624:	6a 00                	push   $0x0
  pushl $40
80106626:	6a 28                	push   $0x28
  jmp alltraps
80106628:	e9 d2 f7 ff ff       	jmp    80105dff <alltraps>

8010662d <vector41>:
.globl vector41
vector41:
  pushl $0
8010662d:	6a 00                	push   $0x0
  pushl $41
8010662f:	6a 29                	push   $0x29
  jmp alltraps
80106631:	e9 c9 f7 ff ff       	jmp    80105dff <alltraps>

80106636 <vector42>:
.globl vector42
vector42:
  pushl $0
80106636:	6a 00                	push   $0x0
  pushl $42
80106638:	6a 2a                	push   $0x2a
  jmp alltraps
8010663a:	e9 c0 f7 ff ff       	jmp    80105dff <alltraps>

8010663f <vector43>:
.globl vector43
vector43:
  pushl $0
8010663f:	6a 00                	push   $0x0
  pushl $43
80106641:	6a 2b                	push   $0x2b
  jmp alltraps
80106643:	e9 b7 f7 ff ff       	jmp    80105dff <alltraps>

80106648 <vector44>:
.globl vector44
vector44:
  pushl $0
80106648:	6a 00                	push   $0x0
  pushl $44
8010664a:	6a 2c                	push   $0x2c
  jmp alltraps
8010664c:	e9 ae f7 ff ff       	jmp    80105dff <alltraps>

80106651 <vector45>:
.globl vector45
vector45:
  pushl $0
80106651:	6a 00                	push   $0x0
  pushl $45
80106653:	6a 2d                	push   $0x2d
  jmp alltraps
80106655:	e9 a5 f7 ff ff       	jmp    80105dff <alltraps>

8010665a <vector46>:
.globl vector46
vector46:
  pushl $0
8010665a:	6a 00                	push   $0x0
  pushl $46
8010665c:	6a 2e                	push   $0x2e
  jmp alltraps
8010665e:	e9 9c f7 ff ff       	jmp    80105dff <alltraps>

80106663 <vector47>:
.globl vector47
vector47:
  pushl $0
80106663:	6a 00                	push   $0x0
  pushl $47
80106665:	6a 2f                	push   $0x2f
  jmp alltraps
80106667:	e9 93 f7 ff ff       	jmp    80105dff <alltraps>

8010666c <vector48>:
.globl vector48
vector48:
  pushl $0
8010666c:	6a 00                	push   $0x0
  pushl $48
8010666e:	6a 30                	push   $0x30
  jmp alltraps
80106670:	e9 8a f7 ff ff       	jmp    80105dff <alltraps>

80106675 <vector49>:
.globl vector49
vector49:
  pushl $0
80106675:	6a 00                	push   $0x0
  pushl $49
80106677:	6a 31                	push   $0x31
  jmp alltraps
80106679:	e9 81 f7 ff ff       	jmp    80105dff <alltraps>

8010667e <vector50>:
.globl vector50
vector50:
  pushl $0
8010667e:	6a 00                	push   $0x0
  pushl $50
80106680:	6a 32                	push   $0x32
  jmp alltraps
80106682:	e9 78 f7 ff ff       	jmp    80105dff <alltraps>

80106687 <vector51>:
.globl vector51
vector51:
  pushl $0
80106687:	6a 00                	push   $0x0
  pushl $51
80106689:	6a 33                	push   $0x33
  jmp alltraps
8010668b:	e9 6f f7 ff ff       	jmp    80105dff <alltraps>

80106690 <vector52>:
.globl vector52
vector52:
  pushl $0
80106690:	6a 00                	push   $0x0
  pushl $52
80106692:	6a 34                	push   $0x34
  jmp alltraps
80106694:	e9 66 f7 ff ff       	jmp    80105dff <alltraps>

80106699 <vector53>:
.globl vector53
vector53:
  pushl $0
80106699:	6a 00                	push   $0x0
  pushl $53
8010669b:	6a 35                	push   $0x35
  jmp alltraps
8010669d:	e9 5d f7 ff ff       	jmp    80105dff <alltraps>

801066a2 <vector54>:
.globl vector54
vector54:
  pushl $0
801066a2:	6a 00                	push   $0x0
  pushl $54
801066a4:	6a 36                	push   $0x36
  jmp alltraps
801066a6:	e9 54 f7 ff ff       	jmp    80105dff <alltraps>

801066ab <vector55>:
.globl vector55
vector55:
  pushl $0
801066ab:	6a 00                	push   $0x0
  pushl $55
801066ad:	6a 37                	push   $0x37
  jmp alltraps
801066af:	e9 4b f7 ff ff       	jmp    80105dff <alltraps>

801066b4 <vector56>:
.globl vector56
vector56:
  pushl $0
801066b4:	6a 00                	push   $0x0
  pushl $56
801066b6:	6a 38                	push   $0x38
  jmp alltraps
801066b8:	e9 42 f7 ff ff       	jmp    80105dff <alltraps>

801066bd <vector57>:
.globl vector57
vector57:
  pushl $0
801066bd:	6a 00                	push   $0x0
  pushl $57
801066bf:	6a 39                	push   $0x39
  jmp alltraps
801066c1:	e9 39 f7 ff ff       	jmp    80105dff <alltraps>

801066c6 <vector58>:
.globl vector58
vector58:
  pushl $0
801066c6:	6a 00                	push   $0x0
  pushl $58
801066c8:	6a 3a                	push   $0x3a
  jmp alltraps
801066ca:	e9 30 f7 ff ff       	jmp    80105dff <alltraps>

801066cf <vector59>:
.globl vector59
vector59:
  pushl $0
801066cf:	6a 00                	push   $0x0
  pushl $59
801066d1:	6a 3b                	push   $0x3b
  jmp alltraps
801066d3:	e9 27 f7 ff ff       	jmp    80105dff <alltraps>

801066d8 <vector60>:
.globl vector60
vector60:
  pushl $0
801066d8:	6a 00                	push   $0x0
  pushl $60
801066da:	6a 3c                	push   $0x3c
  jmp alltraps
801066dc:	e9 1e f7 ff ff       	jmp    80105dff <alltraps>

801066e1 <vector61>:
.globl vector61
vector61:
  pushl $0
801066e1:	6a 00                	push   $0x0
  pushl $61
801066e3:	6a 3d                	push   $0x3d
  jmp alltraps
801066e5:	e9 15 f7 ff ff       	jmp    80105dff <alltraps>

801066ea <vector62>:
.globl vector62
vector62:
  pushl $0
801066ea:	6a 00                	push   $0x0
  pushl $62
801066ec:	6a 3e                	push   $0x3e
  jmp alltraps
801066ee:	e9 0c f7 ff ff       	jmp    80105dff <alltraps>

801066f3 <vector63>:
.globl vector63
vector63:
  pushl $0
801066f3:	6a 00                	push   $0x0
  pushl $63
801066f5:	6a 3f                	push   $0x3f
  jmp alltraps
801066f7:	e9 03 f7 ff ff       	jmp    80105dff <alltraps>

801066fc <vector64>:
.globl vector64
vector64:
  pushl $0
801066fc:	6a 00                	push   $0x0
  pushl $64
801066fe:	6a 40                	push   $0x40
  jmp alltraps
80106700:	e9 fa f6 ff ff       	jmp    80105dff <alltraps>

80106705 <vector65>:
.globl vector65
vector65:
  pushl $0
80106705:	6a 00                	push   $0x0
  pushl $65
80106707:	6a 41                	push   $0x41
  jmp alltraps
80106709:	e9 f1 f6 ff ff       	jmp    80105dff <alltraps>

8010670e <vector66>:
.globl vector66
vector66:
  pushl $0
8010670e:	6a 00                	push   $0x0
  pushl $66
80106710:	6a 42                	push   $0x42
  jmp alltraps
80106712:	e9 e8 f6 ff ff       	jmp    80105dff <alltraps>

80106717 <vector67>:
.globl vector67
vector67:
  pushl $0
80106717:	6a 00                	push   $0x0
  pushl $67
80106719:	6a 43                	push   $0x43
  jmp alltraps
8010671b:	e9 df f6 ff ff       	jmp    80105dff <alltraps>

80106720 <vector68>:
.globl vector68
vector68:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $68
80106722:	6a 44                	push   $0x44
  jmp alltraps
80106724:	e9 d6 f6 ff ff       	jmp    80105dff <alltraps>

80106729 <vector69>:
.globl vector69
vector69:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $69
8010672b:	6a 45                	push   $0x45
  jmp alltraps
8010672d:	e9 cd f6 ff ff       	jmp    80105dff <alltraps>

80106732 <vector70>:
.globl vector70
vector70:
  pushl $0
80106732:	6a 00                	push   $0x0
  pushl $70
80106734:	6a 46                	push   $0x46
  jmp alltraps
80106736:	e9 c4 f6 ff ff       	jmp    80105dff <alltraps>

8010673b <vector71>:
.globl vector71
vector71:
  pushl $0
8010673b:	6a 00                	push   $0x0
  pushl $71
8010673d:	6a 47                	push   $0x47
  jmp alltraps
8010673f:	e9 bb f6 ff ff       	jmp    80105dff <alltraps>

80106744 <vector72>:
.globl vector72
vector72:
  pushl $0
80106744:	6a 00                	push   $0x0
  pushl $72
80106746:	6a 48                	push   $0x48
  jmp alltraps
80106748:	e9 b2 f6 ff ff       	jmp    80105dff <alltraps>

8010674d <vector73>:
.globl vector73
vector73:
  pushl $0
8010674d:	6a 00                	push   $0x0
  pushl $73
8010674f:	6a 49                	push   $0x49
  jmp alltraps
80106751:	e9 a9 f6 ff ff       	jmp    80105dff <alltraps>

80106756 <vector74>:
.globl vector74
vector74:
  pushl $0
80106756:	6a 00                	push   $0x0
  pushl $74
80106758:	6a 4a                	push   $0x4a
  jmp alltraps
8010675a:	e9 a0 f6 ff ff       	jmp    80105dff <alltraps>

8010675f <vector75>:
.globl vector75
vector75:
  pushl $0
8010675f:	6a 00                	push   $0x0
  pushl $75
80106761:	6a 4b                	push   $0x4b
  jmp alltraps
80106763:	e9 97 f6 ff ff       	jmp    80105dff <alltraps>

80106768 <vector76>:
.globl vector76
vector76:
  pushl $0
80106768:	6a 00                	push   $0x0
  pushl $76
8010676a:	6a 4c                	push   $0x4c
  jmp alltraps
8010676c:	e9 8e f6 ff ff       	jmp    80105dff <alltraps>

80106771 <vector77>:
.globl vector77
vector77:
  pushl $0
80106771:	6a 00                	push   $0x0
  pushl $77
80106773:	6a 4d                	push   $0x4d
  jmp alltraps
80106775:	e9 85 f6 ff ff       	jmp    80105dff <alltraps>

8010677a <vector78>:
.globl vector78
vector78:
  pushl $0
8010677a:	6a 00                	push   $0x0
  pushl $78
8010677c:	6a 4e                	push   $0x4e
  jmp alltraps
8010677e:	e9 7c f6 ff ff       	jmp    80105dff <alltraps>

80106783 <vector79>:
.globl vector79
vector79:
  pushl $0
80106783:	6a 00                	push   $0x0
  pushl $79
80106785:	6a 4f                	push   $0x4f
  jmp alltraps
80106787:	e9 73 f6 ff ff       	jmp    80105dff <alltraps>

8010678c <vector80>:
.globl vector80
vector80:
  pushl $0
8010678c:	6a 00                	push   $0x0
  pushl $80
8010678e:	6a 50                	push   $0x50
  jmp alltraps
80106790:	e9 6a f6 ff ff       	jmp    80105dff <alltraps>

80106795 <vector81>:
.globl vector81
vector81:
  pushl $0
80106795:	6a 00                	push   $0x0
  pushl $81
80106797:	6a 51                	push   $0x51
  jmp alltraps
80106799:	e9 61 f6 ff ff       	jmp    80105dff <alltraps>

8010679e <vector82>:
.globl vector82
vector82:
  pushl $0
8010679e:	6a 00                	push   $0x0
  pushl $82
801067a0:	6a 52                	push   $0x52
  jmp alltraps
801067a2:	e9 58 f6 ff ff       	jmp    80105dff <alltraps>

801067a7 <vector83>:
.globl vector83
vector83:
  pushl $0
801067a7:	6a 00                	push   $0x0
  pushl $83
801067a9:	6a 53                	push   $0x53
  jmp alltraps
801067ab:	e9 4f f6 ff ff       	jmp    80105dff <alltraps>

801067b0 <vector84>:
.globl vector84
vector84:
  pushl $0
801067b0:	6a 00                	push   $0x0
  pushl $84
801067b2:	6a 54                	push   $0x54
  jmp alltraps
801067b4:	e9 46 f6 ff ff       	jmp    80105dff <alltraps>

801067b9 <vector85>:
.globl vector85
vector85:
  pushl $0
801067b9:	6a 00                	push   $0x0
  pushl $85
801067bb:	6a 55                	push   $0x55
  jmp alltraps
801067bd:	e9 3d f6 ff ff       	jmp    80105dff <alltraps>

801067c2 <vector86>:
.globl vector86
vector86:
  pushl $0
801067c2:	6a 00                	push   $0x0
  pushl $86
801067c4:	6a 56                	push   $0x56
  jmp alltraps
801067c6:	e9 34 f6 ff ff       	jmp    80105dff <alltraps>

801067cb <vector87>:
.globl vector87
vector87:
  pushl $0
801067cb:	6a 00                	push   $0x0
  pushl $87
801067cd:	6a 57                	push   $0x57
  jmp alltraps
801067cf:	e9 2b f6 ff ff       	jmp    80105dff <alltraps>

801067d4 <vector88>:
.globl vector88
vector88:
  pushl $0
801067d4:	6a 00                	push   $0x0
  pushl $88
801067d6:	6a 58                	push   $0x58
  jmp alltraps
801067d8:	e9 22 f6 ff ff       	jmp    80105dff <alltraps>

801067dd <vector89>:
.globl vector89
vector89:
  pushl $0
801067dd:	6a 00                	push   $0x0
  pushl $89
801067df:	6a 59                	push   $0x59
  jmp alltraps
801067e1:	e9 19 f6 ff ff       	jmp    80105dff <alltraps>

801067e6 <vector90>:
.globl vector90
vector90:
  pushl $0
801067e6:	6a 00                	push   $0x0
  pushl $90
801067e8:	6a 5a                	push   $0x5a
  jmp alltraps
801067ea:	e9 10 f6 ff ff       	jmp    80105dff <alltraps>

801067ef <vector91>:
.globl vector91
vector91:
  pushl $0
801067ef:	6a 00                	push   $0x0
  pushl $91
801067f1:	6a 5b                	push   $0x5b
  jmp alltraps
801067f3:	e9 07 f6 ff ff       	jmp    80105dff <alltraps>

801067f8 <vector92>:
.globl vector92
vector92:
  pushl $0
801067f8:	6a 00                	push   $0x0
  pushl $92
801067fa:	6a 5c                	push   $0x5c
  jmp alltraps
801067fc:	e9 fe f5 ff ff       	jmp    80105dff <alltraps>

80106801 <vector93>:
.globl vector93
vector93:
  pushl $0
80106801:	6a 00                	push   $0x0
  pushl $93
80106803:	6a 5d                	push   $0x5d
  jmp alltraps
80106805:	e9 f5 f5 ff ff       	jmp    80105dff <alltraps>

8010680a <vector94>:
.globl vector94
vector94:
  pushl $0
8010680a:	6a 00                	push   $0x0
  pushl $94
8010680c:	6a 5e                	push   $0x5e
  jmp alltraps
8010680e:	e9 ec f5 ff ff       	jmp    80105dff <alltraps>

80106813 <vector95>:
.globl vector95
vector95:
  pushl $0
80106813:	6a 00                	push   $0x0
  pushl $95
80106815:	6a 5f                	push   $0x5f
  jmp alltraps
80106817:	e9 e3 f5 ff ff       	jmp    80105dff <alltraps>

8010681c <vector96>:
.globl vector96
vector96:
  pushl $0
8010681c:	6a 00                	push   $0x0
  pushl $96
8010681e:	6a 60                	push   $0x60
  jmp alltraps
80106820:	e9 da f5 ff ff       	jmp    80105dff <alltraps>

80106825 <vector97>:
.globl vector97
vector97:
  pushl $0
80106825:	6a 00                	push   $0x0
  pushl $97
80106827:	6a 61                	push   $0x61
  jmp alltraps
80106829:	e9 d1 f5 ff ff       	jmp    80105dff <alltraps>

8010682e <vector98>:
.globl vector98
vector98:
  pushl $0
8010682e:	6a 00                	push   $0x0
  pushl $98
80106830:	6a 62                	push   $0x62
  jmp alltraps
80106832:	e9 c8 f5 ff ff       	jmp    80105dff <alltraps>

80106837 <vector99>:
.globl vector99
vector99:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $99
80106839:	6a 63                	push   $0x63
  jmp alltraps
8010683b:	e9 bf f5 ff ff       	jmp    80105dff <alltraps>

80106840 <vector100>:
.globl vector100
vector100:
  pushl $0
80106840:	6a 00                	push   $0x0
  pushl $100
80106842:	6a 64                	push   $0x64
  jmp alltraps
80106844:	e9 b6 f5 ff ff       	jmp    80105dff <alltraps>

80106849 <vector101>:
.globl vector101
vector101:
  pushl $0
80106849:	6a 00                	push   $0x0
  pushl $101
8010684b:	6a 65                	push   $0x65
  jmp alltraps
8010684d:	e9 ad f5 ff ff       	jmp    80105dff <alltraps>

80106852 <vector102>:
.globl vector102
vector102:
  pushl $0
80106852:	6a 00                	push   $0x0
  pushl $102
80106854:	6a 66                	push   $0x66
  jmp alltraps
80106856:	e9 a4 f5 ff ff       	jmp    80105dff <alltraps>

8010685b <vector103>:
.globl vector103
vector103:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $103
8010685d:	6a 67                	push   $0x67
  jmp alltraps
8010685f:	e9 9b f5 ff ff       	jmp    80105dff <alltraps>

80106864 <vector104>:
.globl vector104
vector104:
  pushl $0
80106864:	6a 00                	push   $0x0
  pushl $104
80106866:	6a 68                	push   $0x68
  jmp alltraps
80106868:	e9 92 f5 ff ff       	jmp    80105dff <alltraps>

8010686d <vector105>:
.globl vector105
vector105:
  pushl $0
8010686d:	6a 00                	push   $0x0
  pushl $105
8010686f:	6a 69                	push   $0x69
  jmp alltraps
80106871:	e9 89 f5 ff ff       	jmp    80105dff <alltraps>

80106876 <vector106>:
.globl vector106
vector106:
  pushl $0
80106876:	6a 00                	push   $0x0
  pushl $106
80106878:	6a 6a                	push   $0x6a
  jmp alltraps
8010687a:	e9 80 f5 ff ff       	jmp    80105dff <alltraps>

8010687f <vector107>:
.globl vector107
vector107:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $107
80106881:	6a 6b                	push   $0x6b
  jmp alltraps
80106883:	e9 77 f5 ff ff       	jmp    80105dff <alltraps>

80106888 <vector108>:
.globl vector108
vector108:
  pushl $0
80106888:	6a 00                	push   $0x0
  pushl $108
8010688a:	6a 6c                	push   $0x6c
  jmp alltraps
8010688c:	e9 6e f5 ff ff       	jmp    80105dff <alltraps>

80106891 <vector109>:
.globl vector109
vector109:
  pushl $0
80106891:	6a 00                	push   $0x0
  pushl $109
80106893:	6a 6d                	push   $0x6d
  jmp alltraps
80106895:	e9 65 f5 ff ff       	jmp    80105dff <alltraps>

8010689a <vector110>:
.globl vector110
vector110:
  pushl $0
8010689a:	6a 00                	push   $0x0
  pushl $110
8010689c:	6a 6e                	push   $0x6e
  jmp alltraps
8010689e:	e9 5c f5 ff ff       	jmp    80105dff <alltraps>

801068a3 <vector111>:
.globl vector111
vector111:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $111
801068a5:	6a 6f                	push   $0x6f
  jmp alltraps
801068a7:	e9 53 f5 ff ff       	jmp    80105dff <alltraps>

801068ac <vector112>:
.globl vector112
vector112:
  pushl $0
801068ac:	6a 00                	push   $0x0
  pushl $112
801068ae:	6a 70                	push   $0x70
  jmp alltraps
801068b0:	e9 4a f5 ff ff       	jmp    80105dff <alltraps>

801068b5 <vector113>:
.globl vector113
vector113:
  pushl $0
801068b5:	6a 00                	push   $0x0
  pushl $113
801068b7:	6a 71                	push   $0x71
  jmp alltraps
801068b9:	e9 41 f5 ff ff       	jmp    80105dff <alltraps>

801068be <vector114>:
.globl vector114
vector114:
  pushl $0
801068be:	6a 00                	push   $0x0
  pushl $114
801068c0:	6a 72                	push   $0x72
  jmp alltraps
801068c2:	e9 38 f5 ff ff       	jmp    80105dff <alltraps>

801068c7 <vector115>:
.globl vector115
vector115:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $115
801068c9:	6a 73                	push   $0x73
  jmp alltraps
801068cb:	e9 2f f5 ff ff       	jmp    80105dff <alltraps>

801068d0 <vector116>:
.globl vector116
vector116:
  pushl $0
801068d0:	6a 00                	push   $0x0
  pushl $116
801068d2:	6a 74                	push   $0x74
  jmp alltraps
801068d4:	e9 26 f5 ff ff       	jmp    80105dff <alltraps>

801068d9 <vector117>:
.globl vector117
vector117:
  pushl $0
801068d9:	6a 00                	push   $0x0
  pushl $117
801068db:	6a 75                	push   $0x75
  jmp alltraps
801068dd:	e9 1d f5 ff ff       	jmp    80105dff <alltraps>

801068e2 <vector118>:
.globl vector118
vector118:
  pushl $0
801068e2:	6a 00                	push   $0x0
  pushl $118
801068e4:	6a 76                	push   $0x76
  jmp alltraps
801068e6:	e9 14 f5 ff ff       	jmp    80105dff <alltraps>

801068eb <vector119>:
.globl vector119
vector119:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $119
801068ed:	6a 77                	push   $0x77
  jmp alltraps
801068ef:	e9 0b f5 ff ff       	jmp    80105dff <alltraps>

801068f4 <vector120>:
.globl vector120
vector120:
  pushl $0
801068f4:	6a 00                	push   $0x0
  pushl $120
801068f6:	6a 78                	push   $0x78
  jmp alltraps
801068f8:	e9 02 f5 ff ff       	jmp    80105dff <alltraps>

801068fd <vector121>:
.globl vector121
vector121:
  pushl $0
801068fd:	6a 00                	push   $0x0
  pushl $121
801068ff:	6a 79                	push   $0x79
  jmp alltraps
80106901:	e9 f9 f4 ff ff       	jmp    80105dff <alltraps>

80106906 <vector122>:
.globl vector122
vector122:
  pushl $0
80106906:	6a 00                	push   $0x0
  pushl $122
80106908:	6a 7a                	push   $0x7a
  jmp alltraps
8010690a:	e9 f0 f4 ff ff       	jmp    80105dff <alltraps>

8010690f <vector123>:
.globl vector123
vector123:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $123
80106911:	6a 7b                	push   $0x7b
  jmp alltraps
80106913:	e9 e7 f4 ff ff       	jmp    80105dff <alltraps>

80106918 <vector124>:
.globl vector124
vector124:
  pushl $0
80106918:	6a 00                	push   $0x0
  pushl $124
8010691a:	6a 7c                	push   $0x7c
  jmp alltraps
8010691c:	e9 de f4 ff ff       	jmp    80105dff <alltraps>

80106921 <vector125>:
.globl vector125
vector125:
  pushl $0
80106921:	6a 00                	push   $0x0
  pushl $125
80106923:	6a 7d                	push   $0x7d
  jmp alltraps
80106925:	e9 d5 f4 ff ff       	jmp    80105dff <alltraps>

8010692a <vector126>:
.globl vector126
vector126:
  pushl $0
8010692a:	6a 00                	push   $0x0
  pushl $126
8010692c:	6a 7e                	push   $0x7e
  jmp alltraps
8010692e:	e9 cc f4 ff ff       	jmp    80105dff <alltraps>

80106933 <vector127>:
.globl vector127
vector127:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $127
80106935:	6a 7f                	push   $0x7f
  jmp alltraps
80106937:	e9 c3 f4 ff ff       	jmp    80105dff <alltraps>

8010693c <vector128>:
.globl vector128
vector128:
  pushl $0
8010693c:	6a 00                	push   $0x0
  pushl $128
8010693e:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106943:	e9 b7 f4 ff ff       	jmp    80105dff <alltraps>

80106948 <vector129>:
.globl vector129
vector129:
  pushl $0
80106948:	6a 00                	push   $0x0
  pushl $129
8010694a:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010694f:	e9 ab f4 ff ff       	jmp    80105dff <alltraps>

80106954 <vector130>:
.globl vector130
vector130:
  pushl $0
80106954:	6a 00                	push   $0x0
  pushl $130
80106956:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010695b:	e9 9f f4 ff ff       	jmp    80105dff <alltraps>

80106960 <vector131>:
.globl vector131
vector131:
  pushl $0
80106960:	6a 00                	push   $0x0
  pushl $131
80106962:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106967:	e9 93 f4 ff ff       	jmp    80105dff <alltraps>

8010696c <vector132>:
.globl vector132
vector132:
  pushl $0
8010696c:	6a 00                	push   $0x0
  pushl $132
8010696e:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106973:	e9 87 f4 ff ff       	jmp    80105dff <alltraps>

80106978 <vector133>:
.globl vector133
vector133:
  pushl $0
80106978:	6a 00                	push   $0x0
  pushl $133
8010697a:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010697f:	e9 7b f4 ff ff       	jmp    80105dff <alltraps>

80106984 <vector134>:
.globl vector134
vector134:
  pushl $0
80106984:	6a 00                	push   $0x0
  pushl $134
80106986:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010698b:	e9 6f f4 ff ff       	jmp    80105dff <alltraps>

80106990 <vector135>:
.globl vector135
vector135:
  pushl $0
80106990:	6a 00                	push   $0x0
  pushl $135
80106992:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106997:	e9 63 f4 ff ff       	jmp    80105dff <alltraps>

8010699c <vector136>:
.globl vector136
vector136:
  pushl $0
8010699c:	6a 00                	push   $0x0
  pushl $136
8010699e:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801069a3:	e9 57 f4 ff ff       	jmp    80105dff <alltraps>

801069a8 <vector137>:
.globl vector137
vector137:
  pushl $0
801069a8:	6a 00                	push   $0x0
  pushl $137
801069aa:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801069af:	e9 4b f4 ff ff       	jmp    80105dff <alltraps>

801069b4 <vector138>:
.globl vector138
vector138:
  pushl $0
801069b4:	6a 00                	push   $0x0
  pushl $138
801069b6:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801069bb:	e9 3f f4 ff ff       	jmp    80105dff <alltraps>

801069c0 <vector139>:
.globl vector139
vector139:
  pushl $0
801069c0:	6a 00                	push   $0x0
  pushl $139
801069c2:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801069c7:	e9 33 f4 ff ff       	jmp    80105dff <alltraps>

801069cc <vector140>:
.globl vector140
vector140:
  pushl $0
801069cc:	6a 00                	push   $0x0
  pushl $140
801069ce:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801069d3:	e9 27 f4 ff ff       	jmp    80105dff <alltraps>

801069d8 <vector141>:
.globl vector141
vector141:
  pushl $0
801069d8:	6a 00                	push   $0x0
  pushl $141
801069da:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801069df:	e9 1b f4 ff ff       	jmp    80105dff <alltraps>

801069e4 <vector142>:
.globl vector142
vector142:
  pushl $0
801069e4:	6a 00                	push   $0x0
  pushl $142
801069e6:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801069eb:	e9 0f f4 ff ff       	jmp    80105dff <alltraps>

801069f0 <vector143>:
.globl vector143
vector143:
  pushl $0
801069f0:	6a 00                	push   $0x0
  pushl $143
801069f2:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801069f7:	e9 03 f4 ff ff       	jmp    80105dff <alltraps>

801069fc <vector144>:
.globl vector144
vector144:
  pushl $0
801069fc:	6a 00                	push   $0x0
  pushl $144
801069fe:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106a03:	e9 f7 f3 ff ff       	jmp    80105dff <alltraps>

80106a08 <vector145>:
.globl vector145
vector145:
  pushl $0
80106a08:	6a 00                	push   $0x0
  pushl $145
80106a0a:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106a0f:	e9 eb f3 ff ff       	jmp    80105dff <alltraps>

80106a14 <vector146>:
.globl vector146
vector146:
  pushl $0
80106a14:	6a 00                	push   $0x0
  pushl $146
80106a16:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106a1b:	e9 df f3 ff ff       	jmp    80105dff <alltraps>

80106a20 <vector147>:
.globl vector147
vector147:
  pushl $0
80106a20:	6a 00                	push   $0x0
  pushl $147
80106a22:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106a27:	e9 d3 f3 ff ff       	jmp    80105dff <alltraps>

80106a2c <vector148>:
.globl vector148
vector148:
  pushl $0
80106a2c:	6a 00                	push   $0x0
  pushl $148
80106a2e:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106a33:	e9 c7 f3 ff ff       	jmp    80105dff <alltraps>

80106a38 <vector149>:
.globl vector149
vector149:
  pushl $0
80106a38:	6a 00                	push   $0x0
  pushl $149
80106a3a:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106a3f:	e9 bb f3 ff ff       	jmp    80105dff <alltraps>

80106a44 <vector150>:
.globl vector150
vector150:
  pushl $0
80106a44:	6a 00                	push   $0x0
  pushl $150
80106a46:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106a4b:	e9 af f3 ff ff       	jmp    80105dff <alltraps>

80106a50 <vector151>:
.globl vector151
vector151:
  pushl $0
80106a50:	6a 00                	push   $0x0
  pushl $151
80106a52:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106a57:	e9 a3 f3 ff ff       	jmp    80105dff <alltraps>

80106a5c <vector152>:
.globl vector152
vector152:
  pushl $0
80106a5c:	6a 00                	push   $0x0
  pushl $152
80106a5e:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106a63:	e9 97 f3 ff ff       	jmp    80105dff <alltraps>

80106a68 <vector153>:
.globl vector153
vector153:
  pushl $0
80106a68:	6a 00                	push   $0x0
  pushl $153
80106a6a:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106a6f:	e9 8b f3 ff ff       	jmp    80105dff <alltraps>

80106a74 <vector154>:
.globl vector154
vector154:
  pushl $0
80106a74:	6a 00                	push   $0x0
  pushl $154
80106a76:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106a7b:	e9 7f f3 ff ff       	jmp    80105dff <alltraps>

80106a80 <vector155>:
.globl vector155
vector155:
  pushl $0
80106a80:	6a 00                	push   $0x0
  pushl $155
80106a82:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106a87:	e9 73 f3 ff ff       	jmp    80105dff <alltraps>

80106a8c <vector156>:
.globl vector156
vector156:
  pushl $0
80106a8c:	6a 00                	push   $0x0
  pushl $156
80106a8e:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106a93:	e9 67 f3 ff ff       	jmp    80105dff <alltraps>

80106a98 <vector157>:
.globl vector157
vector157:
  pushl $0
80106a98:	6a 00                	push   $0x0
  pushl $157
80106a9a:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106a9f:	e9 5b f3 ff ff       	jmp    80105dff <alltraps>

80106aa4 <vector158>:
.globl vector158
vector158:
  pushl $0
80106aa4:	6a 00                	push   $0x0
  pushl $158
80106aa6:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106aab:	e9 4f f3 ff ff       	jmp    80105dff <alltraps>

80106ab0 <vector159>:
.globl vector159
vector159:
  pushl $0
80106ab0:	6a 00                	push   $0x0
  pushl $159
80106ab2:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106ab7:	e9 43 f3 ff ff       	jmp    80105dff <alltraps>

80106abc <vector160>:
.globl vector160
vector160:
  pushl $0
80106abc:	6a 00                	push   $0x0
  pushl $160
80106abe:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106ac3:	e9 37 f3 ff ff       	jmp    80105dff <alltraps>

80106ac8 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ac8:	6a 00                	push   $0x0
  pushl $161
80106aca:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106acf:	e9 2b f3 ff ff       	jmp    80105dff <alltraps>

80106ad4 <vector162>:
.globl vector162
vector162:
  pushl $0
80106ad4:	6a 00                	push   $0x0
  pushl $162
80106ad6:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106adb:	e9 1f f3 ff ff       	jmp    80105dff <alltraps>

80106ae0 <vector163>:
.globl vector163
vector163:
  pushl $0
80106ae0:	6a 00                	push   $0x0
  pushl $163
80106ae2:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106ae7:	e9 13 f3 ff ff       	jmp    80105dff <alltraps>

80106aec <vector164>:
.globl vector164
vector164:
  pushl $0
80106aec:	6a 00                	push   $0x0
  pushl $164
80106aee:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106af3:	e9 07 f3 ff ff       	jmp    80105dff <alltraps>

80106af8 <vector165>:
.globl vector165
vector165:
  pushl $0
80106af8:	6a 00                	push   $0x0
  pushl $165
80106afa:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106aff:	e9 fb f2 ff ff       	jmp    80105dff <alltraps>

80106b04 <vector166>:
.globl vector166
vector166:
  pushl $0
80106b04:	6a 00                	push   $0x0
  pushl $166
80106b06:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106b0b:	e9 ef f2 ff ff       	jmp    80105dff <alltraps>

80106b10 <vector167>:
.globl vector167
vector167:
  pushl $0
80106b10:	6a 00                	push   $0x0
  pushl $167
80106b12:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106b17:	e9 e3 f2 ff ff       	jmp    80105dff <alltraps>

80106b1c <vector168>:
.globl vector168
vector168:
  pushl $0
80106b1c:	6a 00                	push   $0x0
  pushl $168
80106b1e:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106b23:	e9 d7 f2 ff ff       	jmp    80105dff <alltraps>

80106b28 <vector169>:
.globl vector169
vector169:
  pushl $0
80106b28:	6a 00                	push   $0x0
  pushl $169
80106b2a:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106b2f:	e9 cb f2 ff ff       	jmp    80105dff <alltraps>

80106b34 <vector170>:
.globl vector170
vector170:
  pushl $0
80106b34:	6a 00                	push   $0x0
  pushl $170
80106b36:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106b3b:	e9 bf f2 ff ff       	jmp    80105dff <alltraps>

80106b40 <vector171>:
.globl vector171
vector171:
  pushl $0
80106b40:	6a 00                	push   $0x0
  pushl $171
80106b42:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106b47:	e9 b3 f2 ff ff       	jmp    80105dff <alltraps>

80106b4c <vector172>:
.globl vector172
vector172:
  pushl $0
80106b4c:	6a 00                	push   $0x0
  pushl $172
80106b4e:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106b53:	e9 a7 f2 ff ff       	jmp    80105dff <alltraps>

80106b58 <vector173>:
.globl vector173
vector173:
  pushl $0
80106b58:	6a 00                	push   $0x0
  pushl $173
80106b5a:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106b5f:	e9 9b f2 ff ff       	jmp    80105dff <alltraps>

80106b64 <vector174>:
.globl vector174
vector174:
  pushl $0
80106b64:	6a 00                	push   $0x0
  pushl $174
80106b66:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106b6b:	e9 8f f2 ff ff       	jmp    80105dff <alltraps>

80106b70 <vector175>:
.globl vector175
vector175:
  pushl $0
80106b70:	6a 00                	push   $0x0
  pushl $175
80106b72:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106b77:	e9 83 f2 ff ff       	jmp    80105dff <alltraps>

80106b7c <vector176>:
.globl vector176
vector176:
  pushl $0
80106b7c:	6a 00                	push   $0x0
  pushl $176
80106b7e:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106b83:	e9 77 f2 ff ff       	jmp    80105dff <alltraps>

80106b88 <vector177>:
.globl vector177
vector177:
  pushl $0
80106b88:	6a 00                	push   $0x0
  pushl $177
80106b8a:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106b8f:	e9 6b f2 ff ff       	jmp    80105dff <alltraps>

80106b94 <vector178>:
.globl vector178
vector178:
  pushl $0
80106b94:	6a 00                	push   $0x0
  pushl $178
80106b96:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106b9b:	e9 5f f2 ff ff       	jmp    80105dff <alltraps>

80106ba0 <vector179>:
.globl vector179
vector179:
  pushl $0
80106ba0:	6a 00                	push   $0x0
  pushl $179
80106ba2:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106ba7:	e9 53 f2 ff ff       	jmp    80105dff <alltraps>

80106bac <vector180>:
.globl vector180
vector180:
  pushl $0
80106bac:	6a 00                	push   $0x0
  pushl $180
80106bae:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106bb3:	e9 47 f2 ff ff       	jmp    80105dff <alltraps>

80106bb8 <vector181>:
.globl vector181
vector181:
  pushl $0
80106bb8:	6a 00                	push   $0x0
  pushl $181
80106bba:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106bbf:	e9 3b f2 ff ff       	jmp    80105dff <alltraps>

80106bc4 <vector182>:
.globl vector182
vector182:
  pushl $0
80106bc4:	6a 00                	push   $0x0
  pushl $182
80106bc6:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106bcb:	e9 2f f2 ff ff       	jmp    80105dff <alltraps>

80106bd0 <vector183>:
.globl vector183
vector183:
  pushl $0
80106bd0:	6a 00                	push   $0x0
  pushl $183
80106bd2:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106bd7:	e9 23 f2 ff ff       	jmp    80105dff <alltraps>

80106bdc <vector184>:
.globl vector184
vector184:
  pushl $0
80106bdc:	6a 00                	push   $0x0
  pushl $184
80106bde:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106be3:	e9 17 f2 ff ff       	jmp    80105dff <alltraps>

80106be8 <vector185>:
.globl vector185
vector185:
  pushl $0
80106be8:	6a 00                	push   $0x0
  pushl $185
80106bea:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106bef:	e9 0b f2 ff ff       	jmp    80105dff <alltraps>

80106bf4 <vector186>:
.globl vector186
vector186:
  pushl $0
80106bf4:	6a 00                	push   $0x0
  pushl $186
80106bf6:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106bfb:	e9 ff f1 ff ff       	jmp    80105dff <alltraps>

80106c00 <vector187>:
.globl vector187
vector187:
  pushl $0
80106c00:	6a 00                	push   $0x0
  pushl $187
80106c02:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106c07:	e9 f3 f1 ff ff       	jmp    80105dff <alltraps>

80106c0c <vector188>:
.globl vector188
vector188:
  pushl $0
80106c0c:	6a 00                	push   $0x0
  pushl $188
80106c0e:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106c13:	e9 e7 f1 ff ff       	jmp    80105dff <alltraps>

80106c18 <vector189>:
.globl vector189
vector189:
  pushl $0
80106c18:	6a 00                	push   $0x0
  pushl $189
80106c1a:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106c1f:	e9 db f1 ff ff       	jmp    80105dff <alltraps>

80106c24 <vector190>:
.globl vector190
vector190:
  pushl $0
80106c24:	6a 00                	push   $0x0
  pushl $190
80106c26:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106c2b:	e9 cf f1 ff ff       	jmp    80105dff <alltraps>

80106c30 <vector191>:
.globl vector191
vector191:
  pushl $0
80106c30:	6a 00                	push   $0x0
  pushl $191
80106c32:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106c37:	e9 c3 f1 ff ff       	jmp    80105dff <alltraps>

80106c3c <vector192>:
.globl vector192
vector192:
  pushl $0
80106c3c:	6a 00                	push   $0x0
  pushl $192
80106c3e:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106c43:	e9 b7 f1 ff ff       	jmp    80105dff <alltraps>

80106c48 <vector193>:
.globl vector193
vector193:
  pushl $0
80106c48:	6a 00                	push   $0x0
  pushl $193
80106c4a:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106c4f:	e9 ab f1 ff ff       	jmp    80105dff <alltraps>

80106c54 <vector194>:
.globl vector194
vector194:
  pushl $0
80106c54:	6a 00                	push   $0x0
  pushl $194
80106c56:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106c5b:	e9 9f f1 ff ff       	jmp    80105dff <alltraps>

80106c60 <vector195>:
.globl vector195
vector195:
  pushl $0
80106c60:	6a 00                	push   $0x0
  pushl $195
80106c62:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106c67:	e9 93 f1 ff ff       	jmp    80105dff <alltraps>

80106c6c <vector196>:
.globl vector196
vector196:
  pushl $0
80106c6c:	6a 00                	push   $0x0
  pushl $196
80106c6e:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106c73:	e9 87 f1 ff ff       	jmp    80105dff <alltraps>

80106c78 <vector197>:
.globl vector197
vector197:
  pushl $0
80106c78:	6a 00                	push   $0x0
  pushl $197
80106c7a:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106c7f:	e9 7b f1 ff ff       	jmp    80105dff <alltraps>

80106c84 <vector198>:
.globl vector198
vector198:
  pushl $0
80106c84:	6a 00                	push   $0x0
  pushl $198
80106c86:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106c8b:	e9 6f f1 ff ff       	jmp    80105dff <alltraps>

80106c90 <vector199>:
.globl vector199
vector199:
  pushl $0
80106c90:	6a 00                	push   $0x0
  pushl $199
80106c92:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106c97:	e9 63 f1 ff ff       	jmp    80105dff <alltraps>

80106c9c <vector200>:
.globl vector200
vector200:
  pushl $0
80106c9c:	6a 00                	push   $0x0
  pushl $200
80106c9e:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106ca3:	e9 57 f1 ff ff       	jmp    80105dff <alltraps>

80106ca8 <vector201>:
.globl vector201
vector201:
  pushl $0
80106ca8:	6a 00                	push   $0x0
  pushl $201
80106caa:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106caf:	e9 4b f1 ff ff       	jmp    80105dff <alltraps>

80106cb4 <vector202>:
.globl vector202
vector202:
  pushl $0
80106cb4:	6a 00                	push   $0x0
  pushl $202
80106cb6:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106cbb:	e9 3f f1 ff ff       	jmp    80105dff <alltraps>

80106cc0 <vector203>:
.globl vector203
vector203:
  pushl $0
80106cc0:	6a 00                	push   $0x0
  pushl $203
80106cc2:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106cc7:	e9 33 f1 ff ff       	jmp    80105dff <alltraps>

80106ccc <vector204>:
.globl vector204
vector204:
  pushl $0
80106ccc:	6a 00                	push   $0x0
  pushl $204
80106cce:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106cd3:	e9 27 f1 ff ff       	jmp    80105dff <alltraps>

80106cd8 <vector205>:
.globl vector205
vector205:
  pushl $0
80106cd8:	6a 00                	push   $0x0
  pushl $205
80106cda:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106cdf:	e9 1b f1 ff ff       	jmp    80105dff <alltraps>

80106ce4 <vector206>:
.globl vector206
vector206:
  pushl $0
80106ce4:	6a 00                	push   $0x0
  pushl $206
80106ce6:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106ceb:	e9 0f f1 ff ff       	jmp    80105dff <alltraps>

80106cf0 <vector207>:
.globl vector207
vector207:
  pushl $0
80106cf0:	6a 00                	push   $0x0
  pushl $207
80106cf2:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106cf7:	e9 03 f1 ff ff       	jmp    80105dff <alltraps>

80106cfc <vector208>:
.globl vector208
vector208:
  pushl $0
80106cfc:	6a 00                	push   $0x0
  pushl $208
80106cfe:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106d03:	e9 f7 f0 ff ff       	jmp    80105dff <alltraps>

80106d08 <vector209>:
.globl vector209
vector209:
  pushl $0
80106d08:	6a 00                	push   $0x0
  pushl $209
80106d0a:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106d0f:	e9 eb f0 ff ff       	jmp    80105dff <alltraps>

80106d14 <vector210>:
.globl vector210
vector210:
  pushl $0
80106d14:	6a 00                	push   $0x0
  pushl $210
80106d16:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106d1b:	e9 df f0 ff ff       	jmp    80105dff <alltraps>

80106d20 <vector211>:
.globl vector211
vector211:
  pushl $0
80106d20:	6a 00                	push   $0x0
  pushl $211
80106d22:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106d27:	e9 d3 f0 ff ff       	jmp    80105dff <alltraps>

80106d2c <vector212>:
.globl vector212
vector212:
  pushl $0
80106d2c:	6a 00                	push   $0x0
  pushl $212
80106d2e:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106d33:	e9 c7 f0 ff ff       	jmp    80105dff <alltraps>

80106d38 <vector213>:
.globl vector213
vector213:
  pushl $0
80106d38:	6a 00                	push   $0x0
  pushl $213
80106d3a:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106d3f:	e9 bb f0 ff ff       	jmp    80105dff <alltraps>

80106d44 <vector214>:
.globl vector214
vector214:
  pushl $0
80106d44:	6a 00                	push   $0x0
  pushl $214
80106d46:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106d4b:	e9 af f0 ff ff       	jmp    80105dff <alltraps>

80106d50 <vector215>:
.globl vector215
vector215:
  pushl $0
80106d50:	6a 00                	push   $0x0
  pushl $215
80106d52:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106d57:	e9 a3 f0 ff ff       	jmp    80105dff <alltraps>

80106d5c <vector216>:
.globl vector216
vector216:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $216
80106d5e:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106d63:	e9 97 f0 ff ff       	jmp    80105dff <alltraps>

80106d68 <vector217>:
.globl vector217
vector217:
  pushl $0
80106d68:	6a 00                	push   $0x0
  pushl $217
80106d6a:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106d6f:	e9 8b f0 ff ff       	jmp    80105dff <alltraps>

80106d74 <vector218>:
.globl vector218
vector218:
  pushl $0
80106d74:	6a 00                	push   $0x0
  pushl $218
80106d76:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106d7b:	e9 7f f0 ff ff       	jmp    80105dff <alltraps>

80106d80 <vector219>:
.globl vector219
vector219:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $219
80106d82:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106d87:	e9 73 f0 ff ff       	jmp    80105dff <alltraps>

80106d8c <vector220>:
.globl vector220
vector220:
  pushl $0
80106d8c:	6a 00                	push   $0x0
  pushl $220
80106d8e:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106d93:	e9 67 f0 ff ff       	jmp    80105dff <alltraps>

80106d98 <vector221>:
.globl vector221
vector221:
  pushl $0
80106d98:	6a 00                	push   $0x0
  pushl $221
80106d9a:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106d9f:	e9 5b f0 ff ff       	jmp    80105dff <alltraps>

80106da4 <vector222>:
.globl vector222
vector222:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $222
80106da6:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106dab:	e9 4f f0 ff ff       	jmp    80105dff <alltraps>

80106db0 <vector223>:
.globl vector223
vector223:
  pushl $0
80106db0:	6a 00                	push   $0x0
  pushl $223
80106db2:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106db7:	e9 43 f0 ff ff       	jmp    80105dff <alltraps>

80106dbc <vector224>:
.globl vector224
vector224:
  pushl $0
80106dbc:	6a 00                	push   $0x0
  pushl $224
80106dbe:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106dc3:	e9 37 f0 ff ff       	jmp    80105dff <alltraps>

80106dc8 <vector225>:
.globl vector225
vector225:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $225
80106dca:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106dcf:	e9 2b f0 ff ff       	jmp    80105dff <alltraps>

80106dd4 <vector226>:
.globl vector226
vector226:
  pushl $0
80106dd4:	6a 00                	push   $0x0
  pushl $226
80106dd6:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106ddb:	e9 1f f0 ff ff       	jmp    80105dff <alltraps>

80106de0 <vector227>:
.globl vector227
vector227:
  pushl $0
80106de0:	6a 00                	push   $0x0
  pushl $227
80106de2:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106de7:	e9 13 f0 ff ff       	jmp    80105dff <alltraps>

80106dec <vector228>:
.globl vector228
vector228:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $228
80106dee:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106df3:	e9 07 f0 ff ff       	jmp    80105dff <alltraps>

80106df8 <vector229>:
.globl vector229
vector229:
  pushl $0
80106df8:	6a 00                	push   $0x0
  pushl $229
80106dfa:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106dff:	e9 fb ef ff ff       	jmp    80105dff <alltraps>

80106e04 <vector230>:
.globl vector230
vector230:
  pushl $0
80106e04:	6a 00                	push   $0x0
  pushl $230
80106e06:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106e0b:	e9 ef ef ff ff       	jmp    80105dff <alltraps>

80106e10 <vector231>:
.globl vector231
vector231:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $231
80106e12:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106e17:	e9 e3 ef ff ff       	jmp    80105dff <alltraps>

80106e1c <vector232>:
.globl vector232
vector232:
  pushl $0
80106e1c:	6a 00                	push   $0x0
  pushl $232
80106e1e:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106e23:	e9 d7 ef ff ff       	jmp    80105dff <alltraps>

80106e28 <vector233>:
.globl vector233
vector233:
  pushl $0
80106e28:	6a 00                	push   $0x0
  pushl $233
80106e2a:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106e2f:	e9 cb ef ff ff       	jmp    80105dff <alltraps>

80106e34 <vector234>:
.globl vector234
vector234:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $234
80106e36:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106e3b:	e9 bf ef ff ff       	jmp    80105dff <alltraps>

80106e40 <vector235>:
.globl vector235
vector235:
  pushl $0
80106e40:	6a 00                	push   $0x0
  pushl $235
80106e42:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106e47:	e9 b3 ef ff ff       	jmp    80105dff <alltraps>

80106e4c <vector236>:
.globl vector236
vector236:
  pushl $0
80106e4c:	6a 00                	push   $0x0
  pushl $236
80106e4e:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106e53:	e9 a7 ef ff ff       	jmp    80105dff <alltraps>

80106e58 <vector237>:
.globl vector237
vector237:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $237
80106e5a:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106e5f:	e9 9b ef ff ff       	jmp    80105dff <alltraps>

80106e64 <vector238>:
.globl vector238
vector238:
  pushl $0
80106e64:	6a 00                	push   $0x0
  pushl $238
80106e66:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106e6b:	e9 8f ef ff ff       	jmp    80105dff <alltraps>

80106e70 <vector239>:
.globl vector239
vector239:
  pushl $0
80106e70:	6a 00                	push   $0x0
  pushl $239
80106e72:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106e77:	e9 83 ef ff ff       	jmp    80105dff <alltraps>

80106e7c <vector240>:
.globl vector240
vector240:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $240
80106e7e:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106e83:	e9 77 ef ff ff       	jmp    80105dff <alltraps>

80106e88 <vector241>:
.globl vector241
vector241:
  pushl $0
80106e88:	6a 00                	push   $0x0
  pushl $241
80106e8a:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106e8f:	e9 6b ef ff ff       	jmp    80105dff <alltraps>

80106e94 <vector242>:
.globl vector242
vector242:
  pushl $0
80106e94:	6a 00                	push   $0x0
  pushl $242
80106e96:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106e9b:	e9 5f ef ff ff       	jmp    80105dff <alltraps>

80106ea0 <vector243>:
.globl vector243
vector243:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $243
80106ea2:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106ea7:	e9 53 ef ff ff       	jmp    80105dff <alltraps>

80106eac <vector244>:
.globl vector244
vector244:
  pushl $0
80106eac:	6a 00                	push   $0x0
  pushl $244
80106eae:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106eb3:	e9 47 ef ff ff       	jmp    80105dff <alltraps>

80106eb8 <vector245>:
.globl vector245
vector245:
  pushl $0
80106eb8:	6a 00                	push   $0x0
  pushl $245
80106eba:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106ebf:	e9 3b ef ff ff       	jmp    80105dff <alltraps>

80106ec4 <vector246>:
.globl vector246
vector246:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $246
80106ec6:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106ecb:	e9 2f ef ff ff       	jmp    80105dff <alltraps>

80106ed0 <vector247>:
.globl vector247
vector247:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $247
80106ed2:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106ed7:	e9 23 ef ff ff       	jmp    80105dff <alltraps>

80106edc <vector248>:
.globl vector248
vector248:
  pushl $0
80106edc:	6a 00                	push   $0x0
  pushl $248
80106ede:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106ee3:	e9 17 ef ff ff       	jmp    80105dff <alltraps>

80106ee8 <vector249>:
.globl vector249
vector249:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $249
80106eea:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106eef:	e9 0b ef ff ff       	jmp    80105dff <alltraps>

80106ef4 <vector250>:
.globl vector250
vector250:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $250
80106ef6:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106efb:	e9 ff ee ff ff       	jmp    80105dff <alltraps>

80106f00 <vector251>:
.globl vector251
vector251:
  pushl $0
80106f00:	6a 00                	push   $0x0
  pushl $251
80106f02:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106f07:	e9 f3 ee ff ff       	jmp    80105dff <alltraps>

80106f0c <vector252>:
.globl vector252
vector252:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $252
80106f0e:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106f13:	e9 e7 ee ff ff       	jmp    80105dff <alltraps>

80106f18 <vector253>:
.globl vector253
vector253:
  pushl $0
80106f18:	6a 00                	push   $0x0
  pushl $253
80106f1a:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106f1f:	e9 db ee ff ff       	jmp    80105dff <alltraps>

80106f24 <vector254>:
.globl vector254
vector254:
  pushl $0
80106f24:	6a 00                	push   $0x0
  pushl $254
80106f26:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106f2b:	e9 cf ee ff ff       	jmp    80105dff <alltraps>

80106f30 <vector255>:
.globl vector255
vector255:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $255
80106f32:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106f37:	e9 c3 ee ff ff       	jmp    80105dff <alltraps>

80106f3c <lgdt>:
{
80106f3c:	55                   	push   %ebp
80106f3d:	89 e5                	mov    %esp,%ebp
80106f3f:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106f42:	8b 45 0c             	mov    0xc(%ebp),%eax
80106f45:	83 e8 01             	sub    $0x1,%eax
80106f48:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f4f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f53:	8b 45 08             	mov    0x8(%ebp),%eax
80106f56:	c1 e8 10             	shr    $0x10,%eax
80106f59:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106f5d:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f60:	0f 01 10             	lgdtl  (%eax)
}
80106f63:	90                   	nop
80106f64:	c9                   	leave
80106f65:	c3                   	ret

80106f66 <ltr>:
{
80106f66:	55                   	push   %ebp
80106f67:	89 e5                	mov    %esp,%ebp
80106f69:	83 ec 04             	sub    $0x4,%esp
80106f6c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f6f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106f73:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106f77:	0f 00 d8             	ltr    %eax
}
80106f7a:	90                   	nop
80106f7b:	c9                   	leave
80106f7c:	c3                   	ret

80106f7d <lcr3>:
{
80106f7d:	55                   	push   %ebp
80106f7e:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106f80:	8b 45 08             	mov    0x8(%ebp),%eax
80106f83:	0f 22 d8             	mov    %eax,%cr3
}
80106f86:	90                   	nop
80106f87:	5d                   	pop    %ebp
80106f88:	c3                   	ret

80106f89 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106f89:	55                   	push   %ebp
80106f8a:	89 e5                	mov    %esp,%ebp
80106f8c:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106f8f:	e8 09 ca ff ff       	call   8010399d <cpuid>
80106f94:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106f9a:	05 80 69 19 80       	add    $0x80196980,%eax
80106f9f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa5:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fae:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106fb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb7:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fbe:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fc2:	83 e2 f0             	and    $0xfffffff0,%edx
80106fc5:	83 ca 0a             	or     $0xa,%edx
80106fc8:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fce:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fd2:	83 ca 10             	or     $0x10,%edx
80106fd5:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fdb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fdf:	83 e2 9f             	and    $0xffffff9f,%edx
80106fe2:	88 50 7d             	mov    %dl,0x7d(%eax)
80106fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106fec:	83 ca 80             	or     $0xffffff80,%edx
80106fef:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff5:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ff9:	83 ca 0f             	or     $0xf,%edx
80106ffc:	88 50 7e             	mov    %dl,0x7e(%eax)
80106fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107002:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107006:	83 e2 ef             	and    $0xffffffef,%edx
80107009:	88 50 7e             	mov    %dl,0x7e(%eax)
8010700c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010700f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107013:	83 e2 df             	and    $0xffffffdf,%edx
80107016:	88 50 7e             	mov    %dl,0x7e(%eax)
80107019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107020:	83 ca 40             	or     $0x40,%edx
80107023:	88 50 7e             	mov    %dl,0x7e(%eax)
80107026:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107029:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010702d:	83 ca 80             	or     $0xffffff80,%edx
80107030:	88 50 7e             	mov    %dl,0x7e(%eax)
80107033:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107036:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010703a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703d:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107044:	ff ff 
80107046:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107049:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107050:	00 00 
80107052:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107055:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
8010705c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107066:	83 e2 f0             	and    $0xfffffff0,%edx
80107069:	83 ca 02             	or     $0x2,%edx
8010706c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107075:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010707c:	83 ca 10             	or     $0x10,%edx
8010707f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107088:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010708f:	83 e2 9f             	and    $0xffffff9f,%edx
80107092:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107098:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709b:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801070a2:	83 ca 80             	or     $0xffffff80,%edx
801070a5:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801070ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ae:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070b5:	83 ca 0f             	or     $0xf,%edx
801070b8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070c8:	83 e2 ef             	and    $0xffffffef,%edx
801070cb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070db:	83 e2 df             	and    $0xffffffdf,%edx
801070de:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801070ee:	83 ca 40             	or     $0x40,%edx
801070f1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801070f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070fa:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107101:	83 ca 80             	or     $0xffffff80,%edx
80107104:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010710a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010710d:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107117:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010711e:	ff ff 
80107120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107123:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010712a:	00 00 
8010712c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712f:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107136:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107139:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107140:	83 e2 f0             	and    $0xfffffff0,%edx
80107143:	83 ca 0a             	or     $0xa,%edx
80107146:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010714c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010714f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107156:	83 ca 10             	or     $0x10,%edx
80107159:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010715f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107162:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107169:	83 ca 60             	or     $0x60,%edx
8010716c:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107172:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107175:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010717c:	83 ca 80             	or     $0xffffff80,%edx
8010717f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107188:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010718f:	83 ca 0f             	or     $0xf,%edx
80107192:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107198:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719b:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071a2:	83 e2 ef             	and    $0xffffffef,%edx
801071a5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ae:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071b5:	83 e2 df             	and    $0xffffffdf,%edx
801071b8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071c1:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071c8:	83 ca 40             	or     $0x40,%edx
801071cb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d4:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801071db:	83 ca 80             	or     $0xffffff80,%edx
801071de:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801071e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e7:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801071ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071f1:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801071f8:	ff ff 
801071fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fd:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107204:	00 00 
80107206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107209:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107213:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010721a:	83 e2 f0             	and    $0xfffffff0,%edx
8010721d:	83 ca 02             	or     $0x2,%edx
80107220:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107229:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107230:	83 ca 10             	or     $0x10,%edx
80107233:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107243:	83 ca 60             	or     $0x60,%edx
80107246:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010724c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010724f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107256:	83 ca 80             	or     $0xffffff80,%edx
80107259:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010725f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107262:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107269:	83 ca 0f             	or     $0xf,%edx
8010726c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107272:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107275:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010727c:	83 e2 ef             	and    $0xffffffef,%edx
8010727f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107288:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010728f:	83 e2 df             	and    $0xffffffdf,%edx
80107292:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107298:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010729b:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801072a2:	83 ca 40             	or     $0x40,%edx
801072a5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072ae:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801072b5:	83 ca 80             	or     $0xffffff80,%edx
801072b8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801072be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072c1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801072c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072cb:	83 c0 70             	add    $0x70,%eax
801072ce:	83 ec 08             	sub    $0x8,%esp
801072d1:	6a 30                	push   $0x30
801072d3:	50                   	push   %eax
801072d4:	e8 63 fc ff ff       	call   80106f3c <lgdt>
801072d9:	83 c4 10             	add    $0x10,%esp
}
801072dc:	90                   	nop
801072dd:	c9                   	leave
801072de:	c3                   	ret

801072df <walkpgdir>:
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
//수정.satic 지움
pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801072df:	55                   	push   %ebp
801072e0:	89 e5                	mov    %esp,%ebp
801072e2:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801072e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801072e8:	c1 e8 16             	shr    $0x16,%eax
801072eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801072f2:	8b 45 08             	mov    0x8(%ebp),%eax
801072f5:	01 d0                	add    %edx,%eax
801072f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801072fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072fd:	8b 00                	mov    (%eax),%eax
801072ff:	83 e0 01             	and    $0x1,%eax
80107302:	85 c0                	test   %eax,%eax
80107304:	74 14                	je     8010731a <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107306:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107309:	8b 00                	mov    (%eax),%eax
8010730b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107310:	05 00 00 00 80       	add    $0x80000000,%eax
80107315:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107318:	eb 42                	jmp    8010735c <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010731a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010731e:	74 0e                	je     8010732e <walkpgdir+0x4f>
80107320:	e8 83 b4 ff ff       	call   801027a8 <kalloc>
80107325:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107328:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010732c:	75 07                	jne    80107335 <walkpgdir+0x56>
      return 0;
8010732e:	b8 00 00 00 00       	mov    $0x0,%eax
80107333:	eb 3e                	jmp    80107373 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107335:	83 ec 04             	sub    $0x4,%esp
80107338:	68 00 10 00 00       	push   $0x1000
8010733d:	6a 00                	push   $0x0
8010733f:	ff 75 f4             	push   -0xc(%ebp)
80107342:	e8 3a d7 ff ff       	call   80104a81 <memset>
80107347:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010734a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010734d:	05 00 00 00 80       	add    $0x80000000,%eax
80107352:	83 c8 07             	or     $0x7,%eax
80107355:	89 c2                	mov    %eax,%edx
80107357:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010735a:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010735c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010735f:	c1 e8 0c             	shr    $0xc,%eax
80107362:	25 ff 03 00 00       	and    $0x3ff,%eax
80107367:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010736e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107371:	01 d0                	add    %edx,%eax
}
80107373:	c9                   	leave
80107374:	c3                   	ret

80107375 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned.
//static 지워줌
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107375:	55                   	push   %ebp
80107376:	89 e5                	mov    %esp,%ebp
80107378:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010737b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010737e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107383:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107386:	8b 55 0c             	mov    0xc(%ebp),%edx
80107389:	8b 45 10             	mov    0x10(%ebp),%eax
8010738c:	01 d0                	add    %edx,%eax
8010738e:	83 e8 01             	sub    $0x1,%eax
80107391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107396:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107399:	83 ec 04             	sub    $0x4,%esp
8010739c:	6a 01                	push   $0x1
8010739e:	ff 75 f4             	push   -0xc(%ebp)
801073a1:	ff 75 08             	push   0x8(%ebp)
801073a4:	e8 36 ff ff ff       	call   801072df <walkpgdir>
801073a9:	83 c4 10             	add    $0x10,%esp
801073ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
801073af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801073b3:	75 07                	jne    801073bc <mappages+0x47>
      return -1;
801073b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801073ba:	eb 47                	jmp    80107403 <mappages+0x8e>
    if(*pte & PTE_P)
801073bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073bf:	8b 00                	mov    (%eax),%eax
801073c1:	83 e0 01             	and    $0x1,%eax
801073c4:	85 c0                	test   %eax,%eax
801073c6:	74 0d                	je     801073d5 <mappages+0x60>
      panic("remap");
801073c8:	83 ec 0c             	sub    $0xc,%esp
801073cb:	68 5c a7 10 80       	push   $0x8010a75c
801073d0:	e8 ec 91 ff ff       	call   801005c1 <panic>
    *pte = pa | perm | PTE_P;
801073d5:	8b 45 18             	mov    0x18(%ebp),%eax
801073d8:	0b 45 14             	or     0x14(%ebp),%eax
801073db:	83 c8 01             	or     $0x1,%eax
801073de:	89 c2                	mov    %eax,%edx
801073e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073e3:	89 10                	mov    %edx,(%eax)
    if(a == last)
801073e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801073eb:	74 10                	je     801073fd <mappages+0x88>
      break;
    a += PGSIZE;
801073ed:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801073f4:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801073fb:	eb 9c                	jmp    80107399 <mappages+0x24>
      break;
801073fd:	90                   	nop
  }
  return 0;
801073fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107403:	c9                   	leave
80107404:	c3                   	ret

80107405 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107405:	55                   	push   %ebp
80107406:	89 e5                	mov    %esp,%ebp
80107408:	53                   	push   %ebx
80107409:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
8010740c:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107413:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80107418:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010741d:	29 c2                	sub    %eax,%edx
8010741f:	89 d0                	mov    %edx,%eax
80107421:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107424:	a1 48 6c 19 80       	mov    0x80196c48,%eax
80107429:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010742c:	8b 15 48 6c 19 80    	mov    0x80196c48,%edx
80107432:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80107437:	01 d0                	add    %edx,%eax
80107439:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010743c:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107446:	83 c0 30             	add    $0x30,%eax
80107449:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010744c:	89 10                	mov    %edx,(%eax)
8010744e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107451:	89 50 04             	mov    %edx,0x4(%eax)
80107454:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107457:	89 50 08             	mov    %edx,0x8(%eax)
8010745a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010745d:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
80107460:	e8 43 b3 ff ff       	call   801027a8 <kalloc>
80107465:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107468:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010746c:	75 07                	jne    80107475 <setupkvm+0x70>
    return 0;
8010746e:	b8 00 00 00 00       	mov    $0x0,%eax
80107473:	eb 78                	jmp    801074ed <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107475:	83 ec 04             	sub    $0x4,%esp
80107478:	68 00 10 00 00       	push   $0x1000
8010747d:	6a 00                	push   $0x0
8010747f:	ff 75 f0             	push   -0x10(%ebp)
80107482:	e8 fa d5 ff ff       	call   80104a81 <memset>
80107487:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010748a:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107491:	eb 4e                	jmp    801074e1 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107496:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010749c:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010749f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a2:	8b 58 08             	mov    0x8(%eax),%ebx
801074a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074a8:	8b 40 04             	mov    0x4(%eax),%eax
801074ab:	29 c3                	sub    %eax,%ebx
801074ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074b0:	8b 00                	mov    (%eax),%eax
801074b2:	83 ec 0c             	sub    $0xc,%esp
801074b5:	51                   	push   %ecx
801074b6:	52                   	push   %edx
801074b7:	53                   	push   %ebx
801074b8:	50                   	push   %eax
801074b9:	ff 75 f0             	push   -0x10(%ebp)
801074bc:	e8 b4 fe ff ff       	call   80107375 <mappages>
801074c1:	83 c4 20             	add    $0x20,%esp
801074c4:	85 c0                	test   %eax,%eax
801074c6:	79 15                	jns    801074dd <setupkvm+0xd8>
      freevm(pgdir);
801074c8:	83 ec 0c             	sub    $0xc,%esp
801074cb:	ff 75 f0             	push   -0x10(%ebp)
801074ce:	e8 f5 04 00 00       	call   801079c8 <freevm>
801074d3:	83 c4 10             	add    $0x10,%esp
      return 0;
801074d6:	b8 00 00 00 00       	mov    $0x0,%eax
801074db:	eb 10                	jmp    801074ed <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801074dd:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801074e1:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801074e8:	72 a9                	jb     80107493 <setupkvm+0x8e>
    }
  return pgdir;
801074ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801074ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801074f0:	c9                   	leave
801074f1:	c3                   	ret

801074f2 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801074f2:	55                   	push   %ebp
801074f3:	89 e5                	mov    %esp,%ebp
801074f5:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801074f8:	e8 08 ff ff ff       	call   80107405 <setupkvm>
801074fd:	a3 7c 69 19 80       	mov    %eax,0x8019697c
  switchkvm();
80107502:	e8 03 00 00 00       	call   8010750a <switchkvm>
}
80107507:	90                   	nop
80107508:	c9                   	leave
80107509:	c3                   	ret

8010750a <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010750a:	55                   	push   %ebp
8010750b:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010750d:	a1 7c 69 19 80       	mov    0x8019697c,%eax
80107512:	05 00 00 00 80       	add    $0x80000000,%eax
80107517:	50                   	push   %eax
80107518:	e8 60 fa ff ff       	call   80106f7d <lcr3>
8010751d:	83 c4 04             	add    $0x4,%esp
}
80107520:	90                   	nop
80107521:	c9                   	leave
80107522:	c3                   	ret

80107523 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107523:	55                   	push   %ebp
80107524:	89 e5                	mov    %esp,%ebp
80107526:	56                   	push   %esi
80107527:	53                   	push   %ebx
80107528:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010752b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010752f:	75 0d                	jne    8010753e <switchuvm+0x1b>
    panic("switchuvm: no process");
80107531:	83 ec 0c             	sub    $0xc,%esp
80107534:	68 62 a7 10 80       	push   $0x8010a762
80107539:	e8 83 90 ff ff       	call   801005c1 <panic>
  if(p->kstack == 0)
8010753e:	8b 45 08             	mov    0x8(%ebp),%eax
80107541:	8b 40 08             	mov    0x8(%eax),%eax
80107544:	85 c0                	test   %eax,%eax
80107546:	75 0d                	jne    80107555 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107548:	83 ec 0c             	sub    $0xc,%esp
8010754b:	68 78 a7 10 80       	push   $0x8010a778
80107550:	e8 6c 90 ff ff       	call   801005c1 <panic>
  if(p->pgdir == 0)
80107555:	8b 45 08             	mov    0x8(%ebp),%eax
80107558:	8b 40 04             	mov    0x4(%eax),%eax
8010755b:	85 c0                	test   %eax,%eax
8010755d:	75 0d                	jne    8010756c <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010755f:	83 ec 0c             	sub    $0xc,%esp
80107562:	68 8d a7 10 80       	push   $0x8010a78d
80107567:	e8 55 90 ff ff       	call   801005c1 <panic>

  pushcli();
8010756c:	e8 05 d4 ff ff       	call   80104976 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107571:	e8 42 c4 ff ff       	call   801039b8 <mycpu>
80107576:	89 c3                	mov    %eax,%ebx
80107578:	e8 3b c4 ff ff       	call   801039b8 <mycpu>
8010757d:	83 c0 08             	add    $0x8,%eax
80107580:	89 c6                	mov    %eax,%esi
80107582:	e8 31 c4 ff ff       	call   801039b8 <mycpu>
80107587:	83 c0 08             	add    $0x8,%eax
8010758a:	c1 e8 10             	shr    $0x10,%eax
8010758d:	88 45 f7             	mov    %al,-0x9(%ebp)
80107590:	e8 23 c4 ff ff       	call   801039b8 <mycpu>
80107595:	83 c0 08             	add    $0x8,%eax
80107598:	c1 e8 18             	shr    $0x18,%eax
8010759b:	89 c2                	mov    %eax,%edx
8010759d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801075a4:	67 00 
801075a6:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801075ad:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801075b1:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801075b7:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075be:	83 e0 f0             	and    $0xfffffff0,%eax
801075c1:	83 c8 09             	or     $0x9,%eax
801075c4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075ca:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075d1:	83 c8 10             	or     $0x10,%eax
801075d4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075da:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075e1:	83 e0 9f             	and    $0xffffff9f,%eax
801075e4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075ea:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801075f1:	83 c8 80             	or     $0xffffff80,%eax
801075f4:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801075fa:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107601:	83 e0 f0             	and    $0xfffffff0,%eax
80107604:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010760a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107611:	83 e0 ef             	and    $0xffffffef,%eax
80107614:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010761a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107621:	83 e0 df             	and    $0xffffffdf,%eax
80107624:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010762a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107631:	83 c8 40             	or     $0x40,%eax
80107634:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010763a:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107641:	83 e0 7f             	and    $0x7f,%eax
80107644:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
8010764a:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80107650:	e8 63 c3 ff ff       	call   801039b8 <mycpu>
80107655:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010765c:	83 e2 ef             	and    $0xffffffef,%edx
8010765f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107665:	e8 4e c3 ff ff       	call   801039b8 <mycpu>
8010766a:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107670:	8b 45 08             	mov    0x8(%ebp),%eax
80107673:	8b 40 08             	mov    0x8(%eax),%eax
80107676:	89 c3                	mov    %eax,%ebx
80107678:	e8 3b c3 ff ff       	call   801039b8 <mycpu>
8010767d:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107683:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107686:	e8 2d c3 ff ff       	call   801039b8 <mycpu>
8010768b:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107691:	83 ec 0c             	sub    $0xc,%esp
80107694:	6a 28                	push   $0x28
80107696:	e8 cb f8 ff ff       	call   80106f66 <ltr>
8010769b:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010769e:	8b 45 08             	mov    0x8(%ebp),%eax
801076a1:	8b 40 04             	mov    0x4(%eax),%eax
801076a4:	05 00 00 00 80       	add    $0x80000000,%eax
801076a9:	83 ec 0c             	sub    $0xc,%esp
801076ac:	50                   	push   %eax
801076ad:	e8 cb f8 ff ff       	call   80106f7d <lcr3>
801076b2:	83 c4 10             	add    $0x10,%esp
  popcli();
801076b5:	e8 09 d3 ff ff       	call   801049c3 <popcli>
}
801076ba:	90                   	nop
801076bb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801076be:	5b                   	pop    %ebx
801076bf:	5e                   	pop    %esi
801076c0:	5d                   	pop    %ebp
801076c1:	c3                   	ret

801076c2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801076c2:	55                   	push   %ebp
801076c3:	89 e5                	mov    %esp,%ebp
801076c5:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801076c8:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801076cf:	76 0d                	jbe    801076de <inituvm+0x1c>
    panic("inituvm: more than a page");
801076d1:	83 ec 0c             	sub    $0xc,%esp
801076d4:	68 a1 a7 10 80       	push   $0x8010a7a1
801076d9:	e8 e3 8e ff ff       	call   801005c1 <panic>
  mem = kalloc();
801076de:	e8 c5 b0 ff ff       	call   801027a8 <kalloc>
801076e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801076e6:	83 ec 04             	sub    $0x4,%esp
801076e9:	68 00 10 00 00       	push   $0x1000
801076ee:	6a 00                	push   $0x0
801076f0:	ff 75 f4             	push   -0xc(%ebp)
801076f3:	e8 89 d3 ff ff       	call   80104a81 <memset>
801076f8:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801076fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076fe:	05 00 00 00 80       	add    $0x80000000,%eax
80107703:	83 ec 0c             	sub    $0xc,%esp
80107706:	6a 06                	push   $0x6
80107708:	50                   	push   %eax
80107709:	68 00 10 00 00       	push   $0x1000
8010770e:	6a 00                	push   $0x0
80107710:	ff 75 08             	push   0x8(%ebp)
80107713:	e8 5d fc ff ff       	call   80107375 <mappages>
80107718:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010771b:	83 ec 04             	sub    $0x4,%esp
8010771e:	ff 75 10             	push   0x10(%ebp)
80107721:	ff 75 0c             	push   0xc(%ebp)
80107724:	ff 75 f4             	push   -0xc(%ebp)
80107727:	e8 14 d4 ff ff       	call   80104b40 <memmove>
8010772c:	83 c4 10             	add    $0x10,%esp
}
8010772f:	90                   	nop
80107730:	c9                   	leave
80107731:	c3                   	ret

80107732 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107732:	55                   	push   %ebp
80107733:	89 e5                	mov    %esp,%ebp
80107735:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107738:	8b 45 0c             	mov    0xc(%ebp),%eax
8010773b:	25 ff 0f 00 00       	and    $0xfff,%eax
80107740:	85 c0                	test   %eax,%eax
80107742:	74 0d                	je     80107751 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107744:	83 ec 0c             	sub    $0xc,%esp
80107747:	68 bc a7 10 80       	push   $0x8010a7bc
8010774c:	e8 70 8e ff ff       	call   801005c1 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107758:	e9 8f 00 00 00       	jmp    801077ec <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010775d:	8b 55 0c             	mov    0xc(%ebp),%edx
80107760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107763:	01 d0                	add    %edx,%eax
80107765:	83 ec 04             	sub    $0x4,%esp
80107768:	6a 00                	push   $0x0
8010776a:	50                   	push   %eax
8010776b:	ff 75 08             	push   0x8(%ebp)
8010776e:	e8 6c fb ff ff       	call   801072df <walkpgdir>
80107773:	83 c4 10             	add    $0x10,%esp
80107776:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107779:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010777d:	75 0d                	jne    8010778c <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010777f:	83 ec 0c             	sub    $0xc,%esp
80107782:	68 df a7 10 80       	push   $0x8010a7df
80107787:	e8 35 8e ff ff       	call   801005c1 <panic>
    pa = PTE_ADDR(*pte);
8010778c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010778f:	8b 00                	mov    (%eax),%eax
80107791:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107796:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107799:	8b 45 18             	mov    0x18(%ebp),%eax
8010779c:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010779f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
801077a4:	77 0b                	ja     801077b1 <loaduvm+0x7f>
      n = sz - i;
801077a6:	8b 45 18             	mov    0x18(%ebp),%eax
801077a9:	2b 45 f4             	sub    -0xc(%ebp),%eax
801077ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
801077af:	eb 07                	jmp    801077b8 <loaduvm+0x86>
    else
      n = PGSIZE;
801077b1:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801077b8:	8b 55 14             	mov    0x14(%ebp),%edx
801077bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077be:	01 d0                	add    %edx,%eax
801077c0:	8b 55 e8             	mov    -0x18(%ebp),%edx
801077c3:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801077c9:	ff 75 f0             	push   -0x10(%ebp)
801077cc:	50                   	push   %eax
801077cd:	52                   	push   %edx
801077ce:	ff 75 10             	push   0x10(%ebp)
801077d1:	e8 08 a7 ff ff       	call   80101ede <readi>
801077d6:	83 c4 10             	add    $0x10,%esp
801077d9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801077dc:	74 07                	je     801077e5 <loaduvm+0xb3>
      return -1;
801077de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801077e3:	eb 18                	jmp    801077fd <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801077e5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077ef:	3b 45 18             	cmp    0x18(%ebp),%eax
801077f2:	0f 82 65 ff ff ff    	jb     8010775d <loaduvm+0x2b>
  }
  return 0;
801077f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801077fd:	c9                   	leave
801077fe:	c3                   	ret

801077ff <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077ff:	55                   	push   %ebp
80107800:	89 e5                	mov    %esp,%ebp
80107802:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80107805:	8b 45 10             	mov    0x10(%ebp),%eax
80107808:	85 c0                	test   %eax,%eax
8010780a:	79 0a                	jns    80107816 <allocuvm+0x17>
    return 0;
8010780c:	b8 00 00 00 00       	mov    $0x0,%eax
80107811:	e9 ec 00 00 00       	jmp    80107902 <allocuvm+0x103>
  if(newsz < oldsz)
80107816:	8b 45 10             	mov    0x10(%ebp),%eax
80107819:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010781c:	73 08                	jae    80107826 <allocuvm+0x27>
    return oldsz;
8010781e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107821:	e9 dc 00 00 00       	jmp    80107902 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107826:	8b 45 0c             	mov    0xc(%ebp),%eax
80107829:	05 ff 0f 00 00       	add    $0xfff,%eax
8010782e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107833:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107836:	e9 b8 00 00 00       	jmp    801078f3 <allocuvm+0xf4>
    mem = kalloc();
8010783b:	e8 68 af ff ff       	call   801027a8 <kalloc>
80107840:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107843:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107847:	75 2e                	jne    80107877 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107849:	83 ec 0c             	sub    $0xc,%esp
8010784c:	68 fd a7 10 80       	push   $0x8010a7fd
80107851:	e8 9e 8b ff ff       	call   801003f4 <cprintf>
80107856:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107859:	83 ec 04             	sub    $0x4,%esp
8010785c:	ff 75 0c             	push   0xc(%ebp)
8010785f:	ff 75 10             	push   0x10(%ebp)
80107862:	ff 75 08             	push   0x8(%ebp)
80107865:	e8 9a 00 00 00       	call   80107904 <deallocuvm>
8010786a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010786d:	b8 00 00 00 00       	mov    $0x0,%eax
80107872:	e9 8b 00 00 00       	jmp    80107902 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107877:	83 ec 04             	sub    $0x4,%esp
8010787a:	68 00 10 00 00       	push   $0x1000
8010787f:	6a 00                	push   $0x0
80107881:	ff 75 f0             	push   -0x10(%ebp)
80107884:	e8 f8 d1 ff ff       	call   80104a81 <memset>
80107889:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010788c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010788f:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107895:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107898:	83 ec 0c             	sub    $0xc,%esp
8010789b:	6a 06                	push   $0x6
8010789d:	52                   	push   %edx
8010789e:	68 00 10 00 00       	push   $0x1000
801078a3:	50                   	push   %eax
801078a4:	ff 75 08             	push   0x8(%ebp)
801078a7:	e8 c9 fa ff ff       	call   80107375 <mappages>
801078ac:	83 c4 20             	add    $0x20,%esp
801078af:	85 c0                	test   %eax,%eax
801078b1:	79 39                	jns    801078ec <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801078b3:	83 ec 0c             	sub    $0xc,%esp
801078b6:	68 15 a8 10 80       	push   $0x8010a815
801078bb:	e8 34 8b ff ff       	call   801003f4 <cprintf>
801078c0:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801078c3:	83 ec 04             	sub    $0x4,%esp
801078c6:	ff 75 0c             	push   0xc(%ebp)
801078c9:	ff 75 10             	push   0x10(%ebp)
801078cc:	ff 75 08             	push   0x8(%ebp)
801078cf:	e8 30 00 00 00       	call   80107904 <deallocuvm>
801078d4:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801078d7:	83 ec 0c             	sub    $0xc,%esp
801078da:	ff 75 f0             	push   -0x10(%ebp)
801078dd:	e8 2c ae ff ff       	call   8010270e <kfree>
801078e2:	83 c4 10             	add    $0x10,%esp
      return 0;
801078e5:	b8 00 00 00 00       	mov    $0x0,%eax
801078ea:	eb 16                	jmp    80107902 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801078ec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f6:	3b 45 10             	cmp    0x10(%ebp),%eax
801078f9:	0f 82 3c ff ff ff    	jb     8010783b <allocuvm+0x3c>
    }
  }
  return newsz;
801078ff:	8b 45 10             	mov    0x10(%ebp),%eax
}
80107902:	c9                   	leave
80107903:	c3                   	ret

80107904 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80107904:	55                   	push   %ebp
80107905:	89 e5                	mov    %esp,%ebp
80107907:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010790a:	8b 45 10             	mov    0x10(%ebp),%eax
8010790d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107910:	72 08                	jb     8010791a <deallocuvm+0x16>
    return oldsz;
80107912:	8b 45 0c             	mov    0xc(%ebp),%eax
80107915:	e9 ac 00 00 00       	jmp    801079c6 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010791a:	8b 45 10             	mov    0x10(%ebp),%eax
8010791d:	05 ff 0f 00 00       	add    $0xfff,%eax
80107922:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107927:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010792a:	e9 88 00 00 00       	jmp    801079b7 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010792f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107932:	83 ec 04             	sub    $0x4,%esp
80107935:	6a 00                	push   $0x0
80107937:	50                   	push   %eax
80107938:	ff 75 08             	push   0x8(%ebp)
8010793b:	e8 9f f9 ff ff       	call   801072df <walkpgdir>
80107940:	83 c4 10             	add    $0x10,%esp
80107943:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107946:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010794a:	75 16                	jne    80107962 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010794c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794f:	c1 e8 16             	shr    $0x16,%eax
80107952:	83 c0 01             	add    $0x1,%eax
80107955:	c1 e0 16             	shl    $0x16,%eax
80107958:	2d 00 10 00 00       	sub    $0x1000,%eax
8010795d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107960:	eb 4e                	jmp    801079b0 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107965:	8b 00                	mov    (%eax),%eax
80107967:	83 e0 01             	and    $0x1,%eax
8010796a:	85 c0                	test   %eax,%eax
8010796c:	74 42                	je     801079b0 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010796e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107971:	8b 00                	mov    (%eax),%eax
80107973:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107978:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010797b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010797f:	75 0d                	jne    8010798e <deallocuvm+0x8a>
        panic("kfree");
80107981:	83 ec 0c             	sub    $0xc,%esp
80107984:	68 31 a8 10 80       	push   $0x8010a831
80107989:	e8 33 8c ff ff       	call   801005c1 <panic>
      char *v = P2V(pa);
8010798e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107991:	05 00 00 00 80       	add    $0x80000000,%eax
80107996:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107999:	83 ec 0c             	sub    $0xc,%esp
8010799c:	ff 75 e8             	push   -0x18(%ebp)
8010799f:	e8 6a ad ff ff       	call   8010270e <kfree>
801079a4:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
801079a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801079aa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
801079b0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801079b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ba:	3b 45 0c             	cmp    0xc(%ebp),%eax
801079bd:	0f 82 6c ff ff ff    	jb     8010792f <deallocuvm+0x2b>
    }
  }
  return newsz;
801079c3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801079c6:	c9                   	leave
801079c7:	c3                   	ret

801079c8 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801079c8:	55                   	push   %ebp
801079c9:	89 e5                	mov    %esp,%ebp
801079cb:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801079ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801079d2:	75 0d                	jne    801079e1 <freevm+0x19>
    panic("freevm: no pgdir");
801079d4:	83 ec 0c             	sub    $0xc,%esp
801079d7:	68 37 a8 10 80       	push   $0x8010a837
801079dc:	e8 e0 8b ff ff       	call   801005c1 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801079e1:	83 ec 04             	sub    $0x4,%esp
801079e4:	6a 00                	push   $0x0
801079e6:	68 00 00 00 80       	push   $0x80000000
801079eb:	ff 75 08             	push   0x8(%ebp)
801079ee:	e8 11 ff ff ff       	call   80107904 <deallocuvm>
801079f3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801079f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079fd:	eb 48                	jmp    80107a47 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801079ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a02:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a09:	8b 45 08             	mov    0x8(%ebp),%eax
80107a0c:	01 d0                	add    %edx,%eax
80107a0e:	8b 00                	mov    (%eax),%eax
80107a10:	83 e0 01             	and    $0x1,%eax
80107a13:	85 c0                	test   %eax,%eax
80107a15:	74 2c                	je     80107a43 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107a21:	8b 45 08             	mov    0x8(%ebp),%eax
80107a24:	01 d0                	add    %edx,%eax
80107a26:	8b 00                	mov    (%eax),%eax
80107a28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a2d:	05 00 00 00 80       	add    $0x80000000,%eax
80107a32:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107a35:	83 ec 0c             	sub    $0xc,%esp
80107a38:	ff 75 f0             	push   -0x10(%ebp)
80107a3b:	e8 ce ac ff ff       	call   8010270e <kfree>
80107a40:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107a43:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107a47:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80107a4e:	76 af                	jbe    801079ff <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80107a50:	83 ec 0c             	sub    $0xc,%esp
80107a53:	ff 75 08             	push   0x8(%ebp)
80107a56:	e8 b3 ac ff ff       	call   8010270e <kfree>
80107a5b:	83 c4 10             	add    $0x10,%esp
}
80107a5e:	90                   	nop
80107a5f:	c9                   	leave
80107a60:	c3                   	ret

80107a61 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107a61:	55                   	push   %ebp
80107a62:	89 e5                	mov    %esp,%ebp
80107a64:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107a67:	83 ec 04             	sub    $0x4,%esp
80107a6a:	6a 00                	push   $0x0
80107a6c:	ff 75 0c             	push   0xc(%ebp)
80107a6f:	ff 75 08             	push   0x8(%ebp)
80107a72:	e8 68 f8 ff ff       	call   801072df <walkpgdir>
80107a77:	83 c4 10             	add    $0x10,%esp
80107a7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80107a7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107a81:	75 0d                	jne    80107a90 <clearpteu+0x2f>
    panic("clearpteu");
80107a83:	83 ec 0c             	sub    $0xc,%esp
80107a86:	68 48 a8 10 80       	push   $0x8010a848
80107a8b:	e8 31 8b ff ff       	call   801005c1 <panic>
  *pte &= ~PTE_U;
80107a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a93:	8b 00                	mov    (%eax),%eax
80107a95:	83 e0 fb             	and    $0xfffffffb,%eax
80107a98:	89 c2                	mov    %eax,%edx
80107a9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9d:	89 10                	mov    %edx,(%eax)
}
80107a9f:	90                   	nop
80107aa0:	c9                   	leave
80107aa1:	c3                   	ret

80107aa2 <copyuvm>:
  return 0;
}*/
//수정
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107aa2:	55                   	push   %ebp
80107aa3:	89 e5                	mov    %esp,%ebp
80107aa5:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;
 
  if((d = setupkvm()) == 0){
80107aa8:	e8 58 f9 ff ff       	call   80107405 <setupkvm>
80107aad:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107ab0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107ab4:	75 0a                	jne    80107ac0 <copyuvm+0x1e>
    return 0;
80107ab6:	b8 00 00 00 00       	mov    $0x0,%eax
80107abb:	e9 d6 00 00 00       	jmp    80107b96 <copyuvm+0xf4>
  }
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107ac0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ac7:	e9 a3 00 00 00       	jmp    80107b6f <copyuvm+0xcd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0){
80107acc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acf:	83 ec 04             	sub    $0x4,%esp
80107ad2:	6a 00                	push   $0x0
80107ad4:	50                   	push   %eax
80107ad5:	ff 75 08             	push   0x8(%ebp)
80107ad8:	e8 02 f8 ff ff       	call   801072df <walkpgdir>
80107add:	83 c4 10             	add    $0x10,%esp
80107ae0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ae3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ae7:	74 7b                	je     80107b64 <copyuvm+0xc2>
      continue;
    }
    if(!(*pte & PTE_P)){ 
80107ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107aec:	8b 00                	mov    (%eax),%eax
80107aee:	83 e0 01             	and    $0x1,%eax
80107af1:	85 c0                	test   %eax,%eax
80107af3:	74 72                	je     80107b67 <copyuvm+0xc5>
      continue;
    }
    pa = PTE_ADDR(*pte);             
80107af5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107af8:	8b 00                	mov    (%eax),%eax
80107afa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107aff:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b05:	8b 00                	mov    (%eax),%eax
80107b07:	25 ff 0f 00 00       	and    $0xfff,%eax
80107b0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0){
80107b0f:	e8 94 ac ff ff       	call   801027a8 <kalloc>
80107b14:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107b17:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107b1b:	74 62                	je     80107b7f <copyuvm+0xdd>
      goto bad;
    } 
    memmove(mem, (char*)P2V(pa), PGSIZE); //dest, src, size
80107b1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b20:	05 00 00 00 80       	add    $0x80000000,%eax
80107b25:	83 ec 04             	sub    $0x4,%esp
80107b28:	68 00 10 00 00       	push   $0x1000
80107b2d:	50                   	push   %eax
80107b2e:	ff 75 e0             	push   -0x20(%ebp)
80107b31:	e8 0a d0 ff ff       	call   80104b40 <memmove>
80107b36:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0){
80107b39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107b3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107b3f:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	83 ec 0c             	sub    $0xc,%esp
80107b4b:	52                   	push   %edx
80107b4c:	51                   	push   %ecx
80107b4d:	68 00 10 00 00       	push   $0x1000
80107b52:	50                   	push   %eax
80107b53:	ff 75 f0             	push   -0x10(%ebp)
80107b56:	e8 1a f8 ff ff       	call   80107375 <mappages>
80107b5b:	83 c4 20             	add    $0x20,%esp
80107b5e:	85 c0                	test   %eax,%eax
80107b60:	78 20                	js     80107b82 <copyuvm+0xe0>
80107b62:	eb 04                	jmp    80107b68 <copyuvm+0xc6>
      continue;
80107b64:	90                   	nop
80107b65:	eb 01                	jmp    80107b68 <copyuvm+0xc6>
      continue;
80107b67:	90                   	nop
  for(i = 0; i < KERNBASE; i += PGSIZE){
80107b68:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b72:	85 c0                	test   %eax,%eax
80107b74:	0f 89 52 ff ff ff    	jns    80107acc <copyuvm+0x2a>
      goto bad;
    }
  } 
  return d;
80107b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b7d:	eb 17                	jmp    80107b96 <copyuvm+0xf4>
      goto bad;
80107b7f:	90                   	nop
80107b80:	eb 01                	jmp    80107b83 <copyuvm+0xe1>
      goto bad;
80107b82:	90                   	nop
bad:
  freevm(d);
80107b83:	83 ec 0c             	sub    $0xc,%esp
80107b86:	ff 75 f0             	push   -0x10(%ebp)
80107b89:	e8 3a fe ff ff       	call   801079c8 <freevm>
80107b8e:	83 c4 10             	add    $0x10,%esp
  return 0;
80107b91:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b96:	c9                   	leave
80107b97:	c3                   	ret

80107b98 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107b98:	55                   	push   %ebp
80107b99:	89 e5                	mov    %esp,%ebp
80107b9b:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107b9e:	83 ec 04             	sub    $0x4,%esp
80107ba1:	6a 00                	push   $0x0
80107ba3:	ff 75 0c             	push   0xc(%ebp)
80107ba6:	ff 75 08             	push   0x8(%ebp)
80107ba9:	e8 31 f7 ff ff       	call   801072df <walkpgdir>
80107bae:	83 c4 10             	add    $0x10,%esp
80107bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb7:	8b 00                	mov    (%eax),%eax
80107bb9:	83 e0 01             	and    $0x1,%eax
80107bbc:	85 c0                	test   %eax,%eax
80107bbe:	75 07                	jne    80107bc7 <uva2ka+0x2f>
    return 0;
80107bc0:	b8 00 00 00 00       	mov    $0x0,%eax
80107bc5:	eb 22                	jmp    80107be9 <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bca:	8b 00                	mov    (%eax),%eax
80107bcc:	83 e0 04             	and    $0x4,%eax
80107bcf:	85 c0                	test   %eax,%eax
80107bd1:	75 07                	jne    80107bda <uva2ka+0x42>
    return 0;
80107bd3:	b8 00 00 00 00       	mov    $0x0,%eax
80107bd8:	eb 0f                	jmp    80107be9 <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdd:	8b 00                	mov    (%eax),%eax
80107bdf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107be4:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107be9:	c9                   	leave
80107bea:	c3                   	ret

80107beb <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107beb:	55                   	push   %ebp
80107bec:	89 e5                	mov    %esp,%ebp
80107bee:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107bf1:	8b 45 10             	mov    0x10(%ebp),%eax
80107bf4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107bf7:	eb 7f                	jmp    80107c78 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107bfc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c01:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107c04:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c07:	83 ec 08             	sub    $0x8,%esp
80107c0a:	50                   	push   %eax
80107c0b:	ff 75 08             	push   0x8(%ebp)
80107c0e:	e8 85 ff ff ff       	call   80107b98 <uva2ka>
80107c13:	83 c4 10             	add    $0x10,%esp
80107c16:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107c19:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107c1d:	75 07                	jne    80107c26 <copyout+0x3b>
      return -1;
80107c1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107c24:	eb 61                	jmp    80107c87 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107c26:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c29:	2b 45 0c             	sub    0xc(%ebp),%eax
80107c2c:	05 00 10 00 00       	add    $0x1000,%eax
80107c31:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c37:	39 45 14             	cmp    %eax,0x14(%ebp)
80107c3a:	73 06                	jae    80107c42 <copyout+0x57>
      n = len;
80107c3c:	8b 45 14             	mov    0x14(%ebp),%eax
80107c3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107c42:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c45:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107c48:	89 c2                	mov    %eax,%edx
80107c4a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c4d:	01 d0                	add    %edx,%eax
80107c4f:	83 ec 04             	sub    $0x4,%esp
80107c52:	ff 75 f0             	push   -0x10(%ebp)
80107c55:	ff 75 f4             	push   -0xc(%ebp)
80107c58:	50                   	push   %eax
80107c59:	e8 e2 ce ff ff       	call   80104b40 <memmove>
80107c5e:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107c61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c64:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c6a:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107c6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c70:	05 00 10 00 00       	add    $0x1000,%eax
80107c75:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107c78:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107c7c:	0f 85 77 ff ff ff    	jne    80107bf9 <copyout+0xe>
  }
  return 0;
80107c82:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107c87:	c9                   	leave
80107c88:	c3                   	ret

80107c89 <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107c89:	55                   	push   %ebp
80107c8a:	89 e5                	mov    %esp,%ebp
80107c8c:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107c8f:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107c96:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107c99:	8b 40 08             	mov    0x8(%eax),%eax
80107c9c:	05 00 00 00 80       	add    $0x80000000,%eax
80107ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107ca4:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cae:	8b 40 24             	mov    0x24(%eax),%eax
80107cb1:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107cb6:	c7 05 40 6c 19 80 00 	movl   $0x0,0x80196c40
80107cbd:	00 00 00 

  while(i<madt->len){
80107cc0:	e9 bd 00 00 00       	jmp    80107d82 <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
80107cc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107cc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ccb:	01 d0                	add    %edx,%eax
80107ccd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cd3:	0f b6 00             	movzbl (%eax),%eax
80107cd6:	0f b6 c0             	movzbl %al,%eax
80107cd9:	83 f8 05             	cmp    $0x5,%eax
80107cdc:	0f 87 a0 00 00 00    	ja     80107d82 <mpinit_uefi+0xf9>
80107ce2:	8b 04 85 54 a8 10 80 	mov    -0x7fef57ac(,%eax,4),%eax
80107ce9:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107ceb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107cee:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107cf1:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107cf6:	83 f8 03             	cmp    $0x3,%eax
80107cf9:	7f 28                	jg     80107d23 <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107cfb:	8b 15 40 6c 19 80    	mov    0x80196c40,%edx
80107d01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d04:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107d08:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107d0e:	81 c2 80 69 19 80    	add    $0x80196980,%edx
80107d14:	88 02                	mov    %al,(%edx)
          ncpu++;
80107d16:	a1 40 6c 19 80       	mov    0x80196c40,%eax
80107d1b:	83 c0 01             	add    $0x1,%eax
80107d1e:	a3 40 6c 19 80       	mov    %eax,0x80196c40
        }
        i += lapic_entry->record_len;
80107d23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107d26:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d2a:	0f b6 c0             	movzbl %al,%eax
80107d2d:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d30:	eb 50                	jmp    80107d82 <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107d32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d35:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107d38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d3b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107d3f:	a2 44 6c 19 80       	mov    %al,0x80196c44
        i += ioapic->record_len;
80107d44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107d47:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d4b:	0f b6 c0             	movzbl %al,%eax
80107d4e:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d51:	eb 2f                	jmp    80107d82 <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d56:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107d59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107d5c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d60:	0f b6 c0             	movzbl %al,%eax
80107d63:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d66:	eb 1a                	jmp    80107d82 <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107d68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107d6b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107d6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d71:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107d75:	0f b6 c0             	movzbl %al,%eax
80107d78:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107d7b:	eb 05                	jmp    80107d82 <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
80107d7d:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107d81:	90                   	nop
  while(i<madt->len){
80107d82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d85:	8b 40 04             	mov    0x4(%eax),%eax
80107d88:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107d8b:	0f 82 34 ff ff ff    	jb     80107cc5 <mpinit_uefi+0x3c>
    }
  }

}
80107d91:	90                   	nop
80107d92:	90                   	nop
80107d93:	c9                   	leave
80107d94:	c3                   	ret

80107d95 <inb>:
{
80107d95:	55                   	push   %ebp
80107d96:	89 e5                	mov    %esp,%ebp
80107d98:	83 ec 14             	sub    $0x14,%esp
80107d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80107d9e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107da2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107da6:	89 c2                	mov    %eax,%edx
80107da8:	ec                   	in     (%dx),%al
80107da9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107dac:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107db0:	c9                   	leave
80107db1:	c3                   	ret

80107db2 <outb>:
{
80107db2:	55                   	push   %ebp
80107db3:	89 e5                	mov    %esp,%ebp
80107db5:	83 ec 08             	sub    $0x8,%esp
80107db8:	8b 55 08             	mov    0x8(%ebp),%edx
80107dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
80107dbe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107dc2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107dc5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107dc9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107dcd:	ee                   	out    %al,(%dx)
}
80107dce:	90                   	nop
80107dcf:	c9                   	leave
80107dd0:	c3                   	ret

80107dd1 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107dd1:	55                   	push   %ebp
80107dd2:	89 e5                	mov    %esp,%ebp
80107dd4:	83 ec 28             	sub    $0x28,%esp
80107dd7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dda:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107ddd:	6a 00                	push   $0x0
80107ddf:	68 fa 03 00 00       	push   $0x3fa
80107de4:	e8 c9 ff ff ff       	call   80107db2 <outb>
80107de9:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107dec:	68 80 00 00 00       	push   $0x80
80107df1:	68 fb 03 00 00       	push   $0x3fb
80107df6:	e8 b7 ff ff ff       	call   80107db2 <outb>
80107dfb:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107dfe:	6a 0c                	push   $0xc
80107e00:	68 f8 03 00 00       	push   $0x3f8
80107e05:	e8 a8 ff ff ff       	call   80107db2 <outb>
80107e0a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107e0d:	6a 00                	push   $0x0
80107e0f:	68 f9 03 00 00       	push   $0x3f9
80107e14:	e8 99 ff ff ff       	call   80107db2 <outb>
80107e19:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107e1c:	6a 03                	push   $0x3
80107e1e:	68 fb 03 00 00       	push   $0x3fb
80107e23:	e8 8a ff ff ff       	call   80107db2 <outb>
80107e28:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107e2b:	6a 00                	push   $0x0
80107e2d:	68 fc 03 00 00       	push   $0x3fc
80107e32:	e8 7b ff ff ff       	call   80107db2 <outb>
80107e37:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107e3a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107e41:	eb 11                	jmp    80107e54 <uart_debug+0x83>
80107e43:	83 ec 0c             	sub    $0xc,%esp
80107e46:	6a 0a                	push   $0xa
80107e48:	e8 ec ac ff ff       	call   80102b39 <microdelay>
80107e4d:	83 c4 10             	add    $0x10,%esp
80107e50:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107e54:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107e58:	7f 1a                	jg     80107e74 <uart_debug+0xa3>
80107e5a:	83 ec 0c             	sub    $0xc,%esp
80107e5d:	68 fd 03 00 00       	push   $0x3fd
80107e62:	e8 2e ff ff ff       	call   80107d95 <inb>
80107e67:	83 c4 10             	add    $0x10,%esp
80107e6a:	0f b6 c0             	movzbl %al,%eax
80107e6d:	83 e0 20             	and    $0x20,%eax
80107e70:	85 c0                	test   %eax,%eax
80107e72:	74 cf                	je     80107e43 <uart_debug+0x72>
  outb(COM1+0, p);
80107e74:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107e78:	0f b6 c0             	movzbl %al,%eax
80107e7b:	83 ec 08             	sub    $0x8,%esp
80107e7e:	50                   	push   %eax
80107e7f:	68 f8 03 00 00       	push   $0x3f8
80107e84:	e8 29 ff ff ff       	call   80107db2 <outb>
80107e89:	83 c4 10             	add    $0x10,%esp
}
80107e8c:	90                   	nop
80107e8d:	c9                   	leave
80107e8e:	c3                   	ret

80107e8f <uart_debugs>:

void uart_debugs(char *p){
80107e8f:	55                   	push   %ebp
80107e90:	89 e5                	mov    %esp,%ebp
80107e92:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107e95:	eb 1b                	jmp    80107eb2 <uart_debugs+0x23>
    uart_debug(*p++);
80107e97:	8b 45 08             	mov    0x8(%ebp),%eax
80107e9a:	8d 50 01             	lea    0x1(%eax),%edx
80107e9d:	89 55 08             	mov    %edx,0x8(%ebp)
80107ea0:	0f b6 00             	movzbl (%eax),%eax
80107ea3:	0f be c0             	movsbl %al,%eax
80107ea6:	83 ec 0c             	sub    $0xc,%esp
80107ea9:	50                   	push   %eax
80107eaa:	e8 22 ff ff ff       	call   80107dd1 <uart_debug>
80107eaf:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107eb2:	8b 45 08             	mov    0x8(%ebp),%eax
80107eb5:	0f b6 00             	movzbl (%eax),%eax
80107eb8:	84 c0                	test   %al,%al
80107eba:	75 db                	jne    80107e97 <uart_debugs+0x8>
  }
}
80107ebc:	90                   	nop
80107ebd:	90                   	nop
80107ebe:	c9                   	leave
80107ebf:	c3                   	ret

80107ec0 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107ec0:	55                   	push   %ebp
80107ec1:	89 e5                	mov    %esp,%ebp
80107ec3:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107ec6:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107ecd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ed0:	8b 50 14             	mov    0x14(%eax),%edx
80107ed3:	8b 40 10             	mov    0x10(%eax),%eax
80107ed6:	a3 48 6c 19 80       	mov    %eax,0x80196c48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107edb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107ede:	8b 50 1c             	mov    0x1c(%eax),%edx
80107ee1:	8b 40 18             	mov    0x18(%eax),%eax
80107ee4:	a3 50 6c 19 80       	mov    %eax,0x80196c50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107ee9:	a1 50 6c 19 80       	mov    0x80196c50,%eax
80107eee:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107ef3:	29 c2                	sub    %eax,%edx
80107ef5:	89 15 4c 6c 19 80    	mov    %edx,0x80196c4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107efb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107efe:	8b 50 24             	mov    0x24(%eax),%edx
80107f01:	8b 40 20             	mov    0x20(%eax),%eax
80107f04:	a3 54 6c 19 80       	mov    %eax,0x80196c54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107f09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f0c:	8b 50 2c             	mov    0x2c(%eax),%edx
80107f0f:	8b 40 28             	mov    0x28(%eax),%eax
80107f12:	a3 58 6c 19 80       	mov    %eax,0x80196c58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107f17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f1a:	8b 50 34             	mov    0x34(%eax),%edx
80107f1d:	8b 40 30             	mov    0x30(%eax),%eax
80107f20:	a3 5c 6c 19 80       	mov    %eax,0x80196c5c
}
80107f25:	90                   	nop
80107f26:	c9                   	leave
80107f27:	c3                   	ret

80107f28 <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107f28:	55                   	push   %ebp
80107f29:	89 e5                	mov    %esp,%ebp
80107f2b:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107f2e:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107f34:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f37:	0f af d0             	imul   %eax,%edx
80107f3a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f3d:	01 d0                	add    %edx,%eax
80107f3f:	c1 e0 02             	shl    $0x2,%eax
80107f42:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107f45:	8b 15 4c 6c 19 80    	mov    0x80196c4c,%edx
80107f4b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f4e:	01 d0                	add    %edx,%eax
80107f50:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107f53:	8b 45 10             	mov    0x10(%ebp),%eax
80107f56:	0f b6 10             	movzbl (%eax),%edx
80107f59:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f5c:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107f5e:	8b 45 10             	mov    0x10(%ebp),%eax
80107f61:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107f65:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f68:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107f6b:	8b 45 10             	mov    0x10(%ebp),%eax
80107f6e:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107f72:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107f75:	88 50 02             	mov    %dl,0x2(%eax)
}
80107f78:	90                   	nop
80107f79:	c9                   	leave
80107f7a:	c3                   	ret

80107f7b <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107f7b:	55                   	push   %ebp
80107f7c:	89 e5                	mov    %esp,%ebp
80107f7e:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107f81:	8b 15 5c 6c 19 80    	mov    0x80196c5c,%edx
80107f87:	8b 45 08             	mov    0x8(%ebp),%eax
80107f8a:	0f af c2             	imul   %edx,%eax
80107f8d:	c1 e0 02             	shl    $0x2,%eax
80107f90:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107f93:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107f99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9c:	29 c2                	sub    %eax,%edx
80107f9e:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa7:	01 c8                	add    %ecx,%eax
80107fa9:	89 c1                	mov    %eax,%ecx
80107fab:	a1 4c 6c 19 80       	mov    0x80196c4c,%eax
80107fb0:	83 ec 04             	sub    $0x4,%esp
80107fb3:	52                   	push   %edx
80107fb4:	51                   	push   %ecx
80107fb5:	50                   	push   %eax
80107fb6:	e8 85 cb ff ff       	call   80104b40 <memmove>
80107fbb:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc1:	8b 0d 4c 6c 19 80    	mov    0x80196c4c,%ecx
80107fc7:	8b 15 50 6c 19 80    	mov    0x80196c50,%edx
80107fcd:	01 d1                	add    %edx,%ecx
80107fcf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fd2:	29 d1                	sub    %edx,%ecx
80107fd4:	89 ca                	mov    %ecx,%edx
80107fd6:	83 ec 04             	sub    $0x4,%esp
80107fd9:	50                   	push   %eax
80107fda:	6a 00                	push   $0x0
80107fdc:	52                   	push   %edx
80107fdd:	e8 9f ca ff ff       	call   80104a81 <memset>
80107fe2:	83 c4 10             	add    $0x10,%esp
}
80107fe5:	90                   	nop
80107fe6:	c9                   	leave
80107fe7:	c3                   	ret

80107fe8 <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107fe8:	55                   	push   %ebp
80107fe9:	89 e5                	mov    %esp,%ebp
80107feb:	53                   	push   %ebx
80107fec:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107fef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107ff6:	e9 b1 00 00 00       	jmp    801080ac <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107ffb:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80108002:	e9 97 00 00 00       	jmp    8010809e <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80108007:	8b 45 10             	mov    0x10(%ebp),%eax
8010800a:	83 e8 20             	sub    $0x20,%eax
8010800d:	6b d0 1e             	imul   $0x1e,%eax,%edx
80108010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108013:	01 d0                	add    %edx,%eax
80108015:	0f b7 84 00 80 a8 10 	movzwl -0x7fef5780(%eax,%eax,1),%eax
8010801c:	80 
8010801d:	0f b7 d0             	movzwl %ax,%edx
80108020:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108023:	bb 01 00 00 00       	mov    $0x1,%ebx
80108028:	89 c1                	mov    %eax,%ecx
8010802a:	d3 e3                	shl    %cl,%ebx
8010802c:	89 d8                	mov    %ebx,%eax
8010802e:	21 d0                	and    %edx,%eax
80108030:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80108033:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108036:	ba 01 00 00 00       	mov    $0x1,%edx
8010803b:	89 c1                	mov    %eax,%ecx
8010803d:	d3 e2                	shl    %cl,%edx
8010803f:	89 d0                	mov    %edx,%eax
80108041:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80108044:	75 2b                	jne    80108071 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80108046:	8b 55 0c             	mov    0xc(%ebp),%edx
80108049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804c:	01 c2                	add    %eax,%edx
8010804e:	b8 0e 00 00 00       	mov    $0xe,%eax
80108053:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108056:	89 c1                	mov    %eax,%ecx
80108058:	8b 45 08             	mov    0x8(%ebp),%eax
8010805b:	01 c8                	add    %ecx,%eax
8010805d:	83 ec 04             	sub    $0x4,%esp
80108060:	68 e0 f4 10 80       	push   $0x8010f4e0
80108065:	52                   	push   %edx
80108066:	50                   	push   %eax
80108067:	e8 bc fe ff ff       	call   80107f28 <graphic_draw_pixel>
8010806c:	83 c4 10             	add    $0x10,%esp
8010806f:	eb 29                	jmp    8010809a <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80108071:	8b 55 0c             	mov    0xc(%ebp),%edx
80108074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108077:	01 c2                	add    %eax,%edx
80108079:	b8 0e 00 00 00       	mov    $0xe,%eax
8010807e:	2b 45 f0             	sub    -0x10(%ebp),%eax
80108081:	89 c1                	mov    %eax,%ecx
80108083:	8b 45 08             	mov    0x8(%ebp),%eax
80108086:	01 c8                	add    %ecx,%eax
80108088:	83 ec 04             	sub    $0x4,%esp
8010808b:	68 60 6c 19 80       	push   $0x80196c60
80108090:	52                   	push   %edx
80108091:	50                   	push   %eax
80108092:	e8 91 fe ff ff       	call   80107f28 <graphic_draw_pixel>
80108097:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
8010809a:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
8010809e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801080a2:	0f 89 5f ff ff ff    	jns    80108007 <font_render+0x1f>
  for(int i=0;i<30;i++){
801080a8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801080ac:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
801080b0:	0f 8e 45 ff ff ff    	jle    80107ffb <font_render+0x13>
      }
    }
  }
}
801080b6:	90                   	nop
801080b7:	90                   	nop
801080b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080bb:	c9                   	leave
801080bc:	c3                   	ret

801080bd <font_render_string>:

void font_render_string(char *string,int row){
801080bd:	55                   	push   %ebp
801080be:	89 e5                	mov    %esp,%ebp
801080c0:	53                   	push   %ebx
801080c1:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
801080c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
801080cb:	eb 33                	jmp    80108100 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
801080cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080d0:	8b 45 08             	mov    0x8(%ebp),%eax
801080d3:	01 d0                	add    %edx,%eax
801080d5:	0f b6 00             	movzbl (%eax),%eax
801080d8:	0f be d8             	movsbl %al,%ebx
801080db:	8b 45 0c             	mov    0xc(%ebp),%eax
801080de:	6b c8 1e             	imul   $0x1e,%eax,%ecx
801080e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801080e4:	89 d0                	mov    %edx,%eax
801080e6:	c1 e0 04             	shl    $0x4,%eax
801080e9:	29 d0                	sub    %edx,%eax
801080eb:	83 c0 02             	add    $0x2,%eax
801080ee:	83 ec 04             	sub    $0x4,%esp
801080f1:	53                   	push   %ebx
801080f2:	51                   	push   %ecx
801080f3:	50                   	push   %eax
801080f4:	e8 ef fe ff ff       	call   80107fe8 <font_render>
801080f9:	83 c4 10             	add    $0x10,%esp
    i++;
801080fc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108100:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108103:	8b 45 08             	mov    0x8(%ebp),%eax
80108106:	01 d0                	add    %edx,%eax
80108108:	0f b6 00             	movzbl (%eax),%eax
8010810b:	84 c0                	test   %al,%al
8010810d:	74 06                	je     80108115 <font_render_string+0x58>
8010810f:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108113:	7e b8                	jle    801080cd <font_render_string+0x10>
  }
}
80108115:	90                   	nop
80108116:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108119:	c9                   	leave
8010811a:	c3                   	ret

8010811b <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010811b:	55                   	push   %ebp
8010811c:	89 e5                	mov    %esp,%ebp
8010811e:	53                   	push   %ebx
8010811f:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108122:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108129:	eb 6b                	jmp    80108196 <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010812b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108132:	eb 58                	jmp    8010818c <pci_init+0x71>
      for(int k=0;k<8;k++){
80108134:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010813b:	eb 45                	jmp    80108182 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
8010813d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108140:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108143:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108146:	83 ec 0c             	sub    $0xc,%esp
80108149:	8d 5d e8             	lea    -0x18(%ebp),%ebx
8010814c:	53                   	push   %ebx
8010814d:	6a 00                	push   $0x0
8010814f:	51                   	push   %ecx
80108150:	52                   	push   %edx
80108151:	50                   	push   %eax
80108152:	e8 b0 00 00 00       	call   80108207 <pci_access_config>
80108157:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010815a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010815d:	0f b7 c0             	movzwl %ax,%eax
80108160:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108165:	74 17                	je     8010817e <pci_init+0x63>
        pci_init_device(i,j,k);
80108167:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010816a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010816d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108170:	83 ec 04             	sub    $0x4,%esp
80108173:	51                   	push   %ecx
80108174:	52                   	push   %edx
80108175:	50                   	push   %eax
80108176:	e8 37 01 00 00       	call   801082b2 <pci_init_device>
8010817b:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
8010817e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108182:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
80108186:	7e b5                	jle    8010813d <pci_init+0x22>
    for(int j=0;j<32;j++){
80108188:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010818c:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108190:	7e a2                	jle    80108134 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108192:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108196:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010819d:	7e 8c                	jle    8010812b <pci_init+0x10>
      }
      }
    }
  }
}
8010819f:	90                   	nop
801081a0:	90                   	nop
801081a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801081a4:	c9                   	leave
801081a5:	c3                   	ret

801081a6 <pci_write_config>:

void pci_write_config(uint config){
801081a6:	55                   	push   %ebp
801081a7:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801081a9:	8b 45 08             	mov    0x8(%ebp),%eax
801081ac:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801081b1:	89 c0                	mov    %eax,%eax
801081b3:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801081b4:	90                   	nop
801081b5:	5d                   	pop    %ebp
801081b6:	c3                   	ret

801081b7 <pci_write_data>:

void pci_write_data(uint config){
801081b7:	55                   	push   %ebp
801081b8:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801081ba:	8b 45 08             	mov    0x8(%ebp),%eax
801081bd:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801081c2:	89 c0                	mov    %eax,%eax
801081c4:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801081c5:	90                   	nop
801081c6:	5d                   	pop    %ebp
801081c7:	c3                   	ret

801081c8 <pci_read_config>:
uint pci_read_config(){
801081c8:	55                   	push   %ebp
801081c9:	89 e5                	mov    %esp,%ebp
801081cb:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801081ce:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801081d3:	ed                   	in     (%dx),%eax
801081d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801081d7:	83 ec 0c             	sub    $0xc,%esp
801081da:	68 c8 00 00 00       	push   $0xc8
801081df:	e8 55 a9 ff ff       	call   80102b39 <microdelay>
801081e4:	83 c4 10             	add    $0x10,%esp
  return data;
801081e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801081ea:	c9                   	leave
801081eb:	c3                   	ret

801081ec <pci_test>:


void pci_test(){
801081ec:	55                   	push   %ebp
801081ed:	89 e5                	mov    %esp,%ebp
801081ef:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801081f2:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801081f9:	ff 75 fc             	push   -0x4(%ebp)
801081fc:	e8 a5 ff ff ff       	call   801081a6 <pci_write_config>
80108201:	83 c4 04             	add    $0x4,%esp
}
80108204:	90                   	nop
80108205:	c9                   	leave
80108206:	c3                   	ret

80108207 <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
80108207:	55                   	push   %ebp
80108208:	89 e5                	mov    %esp,%ebp
8010820a:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010820d:	8b 45 08             	mov    0x8(%ebp),%eax
80108210:	c1 e0 10             	shl    $0x10,%eax
80108213:	25 00 00 ff 00       	and    $0xff0000,%eax
80108218:	89 c2                	mov    %eax,%edx
8010821a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010821d:	c1 e0 0b             	shl    $0xb,%eax
80108220:	0f b7 c0             	movzwl %ax,%eax
80108223:	09 c2                	or     %eax,%edx
80108225:	8b 45 10             	mov    0x10(%ebp),%eax
80108228:	c1 e0 08             	shl    $0x8,%eax
8010822b:	25 00 07 00 00       	and    $0x700,%eax
80108230:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108232:	8b 45 14             	mov    0x14(%ebp),%eax
80108235:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010823a:	09 d0                	or     %edx,%eax
8010823c:	0d 00 00 00 80       	or     $0x80000000,%eax
80108241:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108244:	ff 75 f4             	push   -0xc(%ebp)
80108247:	e8 5a ff ff ff       	call   801081a6 <pci_write_config>
8010824c:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
8010824f:	e8 74 ff ff ff       	call   801081c8 <pci_read_config>
80108254:	8b 55 18             	mov    0x18(%ebp),%edx
80108257:	89 02                	mov    %eax,(%edx)
}
80108259:	90                   	nop
8010825a:	c9                   	leave
8010825b:	c3                   	ret

8010825c <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
8010825c:	55                   	push   %ebp
8010825d:	89 e5                	mov    %esp,%ebp
8010825f:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108262:	8b 45 08             	mov    0x8(%ebp),%eax
80108265:	c1 e0 10             	shl    $0x10,%eax
80108268:	25 00 00 ff 00       	and    $0xff0000,%eax
8010826d:	89 c2                	mov    %eax,%edx
8010826f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108272:	c1 e0 0b             	shl    $0xb,%eax
80108275:	0f b7 c0             	movzwl %ax,%eax
80108278:	09 c2                	or     %eax,%edx
8010827a:	8b 45 10             	mov    0x10(%ebp),%eax
8010827d:	c1 e0 08             	shl    $0x8,%eax
80108280:	25 00 07 00 00       	and    $0x700,%eax
80108285:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108287:	8b 45 14             	mov    0x14(%ebp),%eax
8010828a:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010828f:	09 d0                	or     %edx,%eax
80108291:	0d 00 00 00 80       	or     $0x80000000,%eax
80108296:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
80108299:	ff 75 fc             	push   -0x4(%ebp)
8010829c:	e8 05 ff ff ff       	call   801081a6 <pci_write_config>
801082a1:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801082a4:	ff 75 18             	push   0x18(%ebp)
801082a7:	e8 0b ff ff ff       	call   801081b7 <pci_write_data>
801082ac:	83 c4 04             	add    $0x4,%esp
}
801082af:	90                   	nop
801082b0:	c9                   	leave
801082b1:	c3                   	ret

801082b2 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801082b2:	55                   	push   %ebp
801082b3:	89 e5                	mov    %esp,%ebp
801082b5:	53                   	push   %ebx
801082b6:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801082b9:	8b 45 08             	mov    0x8(%ebp),%eax
801082bc:	a2 64 6c 19 80       	mov    %al,0x80196c64
  dev.device_num = device_num;
801082c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801082c4:	a2 65 6c 19 80       	mov    %al,0x80196c65
  dev.function_num = function_num;
801082c9:	8b 45 10             	mov    0x10(%ebp),%eax
801082cc:	a2 66 6c 19 80       	mov    %al,0x80196c66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801082d1:	ff 75 10             	push   0x10(%ebp)
801082d4:	ff 75 0c             	push   0xc(%ebp)
801082d7:	ff 75 08             	push   0x8(%ebp)
801082da:	68 c4 be 10 80       	push   $0x8010bec4
801082df:	e8 10 81 ff ff       	call   801003f4 <cprintf>
801082e4:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801082e7:	83 ec 0c             	sub    $0xc,%esp
801082ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082ed:	50                   	push   %eax
801082ee:	6a 00                	push   $0x0
801082f0:	ff 75 10             	push   0x10(%ebp)
801082f3:	ff 75 0c             	push   0xc(%ebp)
801082f6:	ff 75 08             	push   0x8(%ebp)
801082f9:	e8 09 ff ff ff       	call   80108207 <pci_access_config>
801082fe:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108301:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108304:	c1 e8 10             	shr    $0x10,%eax
80108307:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010830a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010830d:	25 ff ff 00 00       	and    $0xffff,%eax
80108312:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108318:	a3 68 6c 19 80       	mov    %eax,0x80196c68
  dev.vendor_id = vendor_id;
8010831d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108320:	a3 6c 6c 19 80       	mov    %eax,0x80196c6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108325:	83 ec 04             	sub    $0x4,%esp
80108328:	ff 75 f0             	push   -0x10(%ebp)
8010832b:	ff 75 f4             	push   -0xc(%ebp)
8010832e:	68 f8 be 10 80       	push   $0x8010bef8
80108333:	e8 bc 80 ff ff       	call   801003f4 <cprintf>
80108338:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010833b:	83 ec 0c             	sub    $0xc,%esp
8010833e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108341:	50                   	push   %eax
80108342:	6a 08                	push   $0x8
80108344:	ff 75 10             	push   0x10(%ebp)
80108347:	ff 75 0c             	push   0xc(%ebp)
8010834a:	ff 75 08             	push   0x8(%ebp)
8010834d:	e8 b5 fe ff ff       	call   80108207 <pci_access_config>
80108352:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108355:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108358:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010835b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010835e:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108361:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108364:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108367:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010836a:	0f b6 c0             	movzbl %al,%eax
8010836d:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108370:	c1 eb 18             	shr    $0x18,%ebx
80108373:	83 ec 0c             	sub    $0xc,%esp
80108376:	51                   	push   %ecx
80108377:	52                   	push   %edx
80108378:	50                   	push   %eax
80108379:	53                   	push   %ebx
8010837a:	68 1c bf 10 80       	push   $0x8010bf1c
8010837f:	e8 70 80 ff ff       	call   801003f4 <cprintf>
80108384:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
80108387:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010838a:	c1 e8 18             	shr    $0x18,%eax
8010838d:	a2 70 6c 19 80       	mov    %al,0x80196c70
  dev.sub_class = (data>>16)&0xFF;
80108392:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108395:	c1 e8 10             	shr    $0x10,%eax
80108398:	a2 71 6c 19 80       	mov    %al,0x80196c71
  dev.interface = (data>>8)&0xFF;
8010839d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083a0:	c1 e8 08             	shr    $0x8,%eax
801083a3:	a2 72 6c 19 80       	mov    %al,0x80196c72
  dev.revision_id = data&0xFF;
801083a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ab:	a2 73 6c 19 80       	mov    %al,0x80196c73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801083b0:	83 ec 0c             	sub    $0xc,%esp
801083b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083b6:	50                   	push   %eax
801083b7:	6a 10                	push   $0x10
801083b9:	ff 75 10             	push   0x10(%ebp)
801083bc:	ff 75 0c             	push   0xc(%ebp)
801083bf:	ff 75 08             	push   0x8(%ebp)
801083c2:	e8 40 fe ff ff       	call   80108207 <pci_access_config>
801083c7:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801083ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083cd:	a3 74 6c 19 80       	mov    %eax,0x80196c74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801083d2:	83 ec 0c             	sub    $0xc,%esp
801083d5:	8d 45 ec             	lea    -0x14(%ebp),%eax
801083d8:	50                   	push   %eax
801083d9:	6a 14                	push   $0x14
801083db:	ff 75 10             	push   0x10(%ebp)
801083de:	ff 75 0c             	push   0xc(%ebp)
801083e1:	ff 75 08             	push   0x8(%ebp)
801083e4:	e8 1e fe ff ff       	call   80108207 <pci_access_config>
801083e9:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801083ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083ef:	a3 78 6c 19 80       	mov    %eax,0x80196c78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801083f4:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801083fb:	75 5a                	jne    80108457 <pci_init_device+0x1a5>
801083fd:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108404:	75 51                	jne    80108457 <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
80108406:	83 ec 0c             	sub    $0xc,%esp
80108409:	68 61 bf 10 80       	push   $0x8010bf61
8010840e:	e8 e1 7f ff ff       	call   801003f4 <cprintf>
80108413:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
80108416:	83 ec 0c             	sub    $0xc,%esp
80108419:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010841c:	50                   	push   %eax
8010841d:	68 f0 00 00 00       	push   $0xf0
80108422:	ff 75 10             	push   0x10(%ebp)
80108425:	ff 75 0c             	push   0xc(%ebp)
80108428:	ff 75 08             	push   0x8(%ebp)
8010842b:	e8 d7 fd ff ff       	call   80108207 <pci_access_config>
80108430:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108433:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108436:	83 ec 08             	sub    $0x8,%esp
80108439:	50                   	push   %eax
8010843a:	68 7b bf 10 80       	push   $0x8010bf7b
8010843f:	e8 b0 7f ff ff       	call   801003f4 <cprintf>
80108444:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
80108447:	83 ec 0c             	sub    $0xc,%esp
8010844a:	68 64 6c 19 80       	push   $0x80196c64
8010844f:	e8 09 00 00 00       	call   8010845d <i8254_init>
80108454:	83 c4 10             	add    $0x10,%esp
  }
}
80108457:	90                   	nop
80108458:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010845b:	c9                   	leave
8010845c:	c3                   	ret

8010845d <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
8010845d:	55                   	push   %ebp
8010845e:	89 e5                	mov    %esp,%ebp
80108460:	53                   	push   %ebx
80108461:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108464:	8b 45 08             	mov    0x8(%ebp),%eax
80108467:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010846b:	0f b6 c8             	movzbl %al,%ecx
8010846e:	8b 45 08             	mov    0x8(%ebp),%eax
80108471:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108475:	0f b6 d0             	movzbl %al,%edx
80108478:	8b 45 08             	mov    0x8(%ebp),%eax
8010847b:	0f b6 00             	movzbl (%eax),%eax
8010847e:	0f b6 c0             	movzbl %al,%eax
80108481:	83 ec 0c             	sub    $0xc,%esp
80108484:	8d 5d ec             	lea    -0x14(%ebp),%ebx
80108487:	53                   	push   %ebx
80108488:	6a 04                	push   $0x4
8010848a:	51                   	push   %ecx
8010848b:	52                   	push   %edx
8010848c:	50                   	push   %eax
8010848d:	e8 75 fd ff ff       	call   80108207 <pci_access_config>
80108492:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108495:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108498:	83 c8 04             	or     $0x4,%eax
8010849b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
8010849e:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801084a1:	8b 45 08             	mov    0x8(%ebp),%eax
801084a4:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801084a8:	0f b6 c8             	movzbl %al,%ecx
801084ab:	8b 45 08             	mov    0x8(%ebp),%eax
801084ae:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801084b2:	0f b6 d0             	movzbl %al,%edx
801084b5:	8b 45 08             	mov    0x8(%ebp),%eax
801084b8:	0f b6 00             	movzbl (%eax),%eax
801084bb:	0f b6 c0             	movzbl %al,%eax
801084be:	83 ec 0c             	sub    $0xc,%esp
801084c1:	53                   	push   %ebx
801084c2:	6a 04                	push   $0x4
801084c4:	51                   	push   %ecx
801084c5:	52                   	push   %edx
801084c6:	50                   	push   %eax
801084c7:	e8 90 fd ff ff       	call   8010825c <pci_write_config_register>
801084cc:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801084cf:	8b 45 08             	mov    0x8(%ebp),%eax
801084d2:	8b 40 10             	mov    0x10(%eax),%eax
801084d5:	05 00 00 00 40       	add    $0x40000000,%eax
801084da:	a3 7c 6c 19 80       	mov    %eax,0x80196c7c
  uint *ctrl = (uint *)base_addr;
801084df:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801084e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801084e7:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801084ec:	05 d8 00 00 00       	add    $0xd8,%eax
801084f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801084f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084f7:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
801084fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108500:	8b 00                	mov    (%eax),%eax
80108502:	0d 00 00 00 04       	or     $0x4000000,%eax
80108507:	89 c2                	mov    %eax,%edx
80108509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010850c:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
8010850e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108511:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
80108517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851a:	8b 00                	mov    (%eax),%eax
8010851c:	83 c8 40             	or     $0x40,%eax
8010851f:	89 c2                	mov    %eax,%edx
80108521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108524:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
80108526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108529:	8b 10                	mov    (%eax),%edx
8010852b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852e:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108530:	83 ec 0c             	sub    $0xc,%esp
80108533:	68 90 bf 10 80       	push   $0x8010bf90
80108538:	e8 b7 7e ff ff       	call   801003f4 <cprintf>
8010853d:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108540:	e8 63 a2 ff ff       	call   801027a8 <kalloc>
80108545:	a3 88 6c 19 80       	mov    %eax,0x80196c88
  *intr_addr = 0;
8010854a:	a1 88 6c 19 80       	mov    0x80196c88,%eax
8010854f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108555:	a1 88 6c 19 80       	mov    0x80196c88,%eax
8010855a:	83 ec 08             	sub    $0x8,%esp
8010855d:	50                   	push   %eax
8010855e:	68 b2 bf 10 80       	push   $0x8010bfb2
80108563:	e8 8c 7e ff ff       	call   801003f4 <cprintf>
80108568:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010856b:	e8 50 00 00 00       	call   801085c0 <i8254_init_recv>
  i8254_init_send();
80108570:	e8 69 03 00 00       	call   801088de <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108575:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010857c:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
8010857f:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108586:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
80108589:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108590:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108593:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010859a:	0f b6 c0             	movzbl %al,%eax
8010859d:	83 ec 0c             	sub    $0xc,%esp
801085a0:	53                   	push   %ebx
801085a1:	51                   	push   %ecx
801085a2:	52                   	push   %edx
801085a3:	50                   	push   %eax
801085a4:	68 c0 bf 10 80       	push   $0x8010bfc0
801085a9:	e8 46 7e ff ff       	call   801003f4 <cprintf>
801085ae:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801085b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801085ba:	90                   	nop
801085bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801085be:	c9                   	leave
801085bf:	c3                   	ret

801085c0 <i8254_init_recv>:

void i8254_init_recv(){
801085c0:	55                   	push   %ebp
801085c1:	89 e5                	mov    %esp,%ebp
801085c3:	57                   	push   %edi
801085c4:	56                   	push   %esi
801085c5:	53                   	push   %ebx
801085c6:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801085c9:	83 ec 0c             	sub    $0xc,%esp
801085cc:	6a 00                	push   $0x0
801085ce:	e8 e8 04 00 00       	call   80108abb <i8254_read_eeprom>
801085d3:	83 c4 10             	add    $0x10,%esp
801085d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801085d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085dc:	a2 80 6c 19 80       	mov    %al,0x80196c80
  mac_addr[1] = data_l>>8;
801085e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
801085e4:	c1 e8 08             	shr    $0x8,%eax
801085e7:	a2 81 6c 19 80       	mov    %al,0x80196c81
  uint data_m = i8254_read_eeprom(0x1);
801085ec:	83 ec 0c             	sub    $0xc,%esp
801085ef:	6a 01                	push   $0x1
801085f1:	e8 c5 04 00 00       	call   80108abb <i8254_read_eeprom>
801085f6:	83 c4 10             	add    $0x10,%esp
801085f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
801085fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085ff:	a2 82 6c 19 80       	mov    %al,0x80196c82
  mac_addr[3] = data_m>>8;
80108604:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108607:	c1 e8 08             	shr    $0x8,%eax
8010860a:	a2 83 6c 19 80       	mov    %al,0x80196c83
  uint data_h = i8254_read_eeprom(0x2);
8010860f:	83 ec 0c             	sub    $0xc,%esp
80108612:	6a 02                	push   $0x2
80108614:	e8 a2 04 00 00       	call   80108abb <i8254_read_eeprom>
80108619:	83 c4 10             	add    $0x10,%esp
8010861c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
8010861f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108622:	a2 84 6c 19 80       	mov    %al,0x80196c84
  mac_addr[5] = data_h>>8;
80108627:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010862a:	c1 e8 08             	shr    $0x8,%eax
8010862d:	a2 85 6c 19 80       	mov    %al,0x80196c85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108632:	0f b6 05 85 6c 19 80 	movzbl 0x80196c85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108639:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
8010863c:	0f b6 05 84 6c 19 80 	movzbl 0x80196c84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108643:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
80108646:	0f b6 05 83 6c 19 80 	movzbl 0x80196c83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010864d:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108650:	0f b6 05 82 6c 19 80 	movzbl 0x80196c82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108657:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010865a:	0f b6 05 81 6c 19 80 	movzbl 0x80196c81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108661:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108664:	0f b6 05 80 6c 19 80 	movzbl 0x80196c80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010866b:	0f b6 c0             	movzbl %al,%eax
8010866e:	83 ec 04             	sub    $0x4,%esp
80108671:	57                   	push   %edi
80108672:	56                   	push   %esi
80108673:	53                   	push   %ebx
80108674:	51                   	push   %ecx
80108675:	52                   	push   %edx
80108676:	50                   	push   %eax
80108677:	68 d8 bf 10 80       	push   $0x8010bfd8
8010867c:	e8 73 7d ff ff       	call   801003f4 <cprintf>
80108681:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108684:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108689:	05 00 54 00 00       	add    $0x5400,%eax
8010868e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108691:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108696:	05 04 54 00 00       	add    $0x5404,%eax
8010869b:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
8010869e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801086a1:	c1 e0 10             	shl    $0x10,%eax
801086a4:	0b 45 d8             	or     -0x28(%ebp),%eax
801086a7:	89 c2                	mov    %eax,%edx
801086a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801086ac:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801086ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
801086b1:	0d 00 00 00 80       	or     $0x80000000,%eax
801086b6:	89 c2                	mov    %eax,%edx
801086b8:	8b 45 c8             	mov    -0x38(%ebp),%eax
801086bb:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801086bd:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086c2:	05 00 52 00 00       	add    $0x5200,%eax
801086c7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801086ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801086d1:	eb 19                	jmp    801086ec <i8254_init_recv+0x12c>
    mta[i] = 0;
801086d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801086d6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801086dd:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801086e0:	01 d0                	add    %edx,%eax
801086e2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801086e8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801086ec:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801086f0:	7e e1                	jle    801086d3 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801086f2:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801086f7:	05 d0 00 00 00       	add    $0xd0,%eax
801086fc:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
801086ff:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108702:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
80108708:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010870d:	05 c8 00 00 00       	add    $0xc8,%eax
80108712:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108715:	8b 45 bc             	mov    -0x44(%ebp),%eax
80108718:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
8010871e:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108723:	05 28 28 00 00       	add    $0x2828,%eax
80108728:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010872b:	8b 45 b8             	mov    -0x48(%ebp),%eax
8010872e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108734:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108739:	05 00 01 00 00       	add    $0x100,%eax
8010873e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108741:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108744:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010874a:	e8 59 a0 ff ff       	call   801027a8 <kalloc>
8010874f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108752:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108757:	05 00 28 00 00       	add    $0x2800,%eax
8010875c:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
8010875f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108764:	05 04 28 00 00       	add    $0x2804,%eax
80108769:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
8010876c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108771:	05 08 28 00 00       	add    $0x2808,%eax
80108776:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
80108779:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010877e:	05 10 28 00 00       	add    $0x2810,%eax
80108783:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108786:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010878b:	05 18 28 00 00       	add    $0x2818,%eax
80108790:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108793:	8b 45 b0             	mov    -0x50(%ebp),%eax
80108796:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010879c:	8b 45 ac             	mov    -0x54(%ebp),%eax
8010879f:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801087a1:	8b 45 a8             	mov    -0x58(%ebp),%eax
801087a4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801087aa:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801087ad:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801087b3:	8b 45 a0             	mov    -0x60(%ebp),%eax
801087b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801087bc:	8b 45 9c             	mov    -0x64(%ebp),%eax
801087bf:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801087c5:	8b 45 b0             	mov    -0x50(%ebp),%eax
801087c8:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801087cb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801087d2:	eb 73                	jmp    80108847 <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801087d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087d7:	c1 e0 04             	shl    $0x4,%eax
801087da:	89 c2                	mov    %eax,%edx
801087dc:	8b 45 98             	mov    -0x68(%ebp),%eax
801087df:	01 d0                	add    %edx,%eax
801087e1:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801087e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087eb:	c1 e0 04             	shl    $0x4,%eax
801087ee:	89 c2                	mov    %eax,%edx
801087f0:	8b 45 98             	mov    -0x68(%ebp),%eax
801087f3:	01 d0                	add    %edx,%eax
801087f5:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801087fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801087fe:	c1 e0 04             	shl    $0x4,%eax
80108801:	89 c2                	mov    %eax,%edx
80108803:	8b 45 98             	mov    -0x68(%ebp),%eax
80108806:	01 d0                	add    %edx,%eax
80108808:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
8010880e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108811:	c1 e0 04             	shl    $0x4,%eax
80108814:	89 c2                	mov    %eax,%edx
80108816:	8b 45 98             	mov    -0x68(%ebp),%eax
80108819:	01 d0                	add    %edx,%eax
8010881b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
8010881f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108822:	c1 e0 04             	shl    $0x4,%eax
80108825:	89 c2                	mov    %eax,%edx
80108827:	8b 45 98             	mov    -0x68(%ebp),%eax
8010882a:	01 d0                	add    %edx,%eax
8010882c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108830:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108833:	c1 e0 04             	shl    $0x4,%eax
80108836:	89 c2                	mov    %eax,%edx
80108838:	8b 45 98             	mov    -0x68(%ebp),%eax
8010883b:	01 d0                	add    %edx,%eax
8010883d:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108843:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
80108847:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
8010884e:	7e 84                	jle    801087d4 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108850:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
80108857:	eb 57                	jmp    801088b0 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
80108859:	e8 4a 9f ff ff       	call   801027a8 <kalloc>
8010885e:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108861:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108865:	75 12                	jne    80108879 <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
80108867:	83 ec 0c             	sub    $0xc,%esp
8010886a:	68 f8 bf 10 80       	push   $0x8010bff8
8010886f:	e8 80 7b ff ff       	call   801003f4 <cprintf>
80108874:	83 c4 10             	add    $0x10,%esp
      break;
80108877:	eb 3d                	jmp    801088b6 <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
80108879:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010887c:	c1 e0 04             	shl    $0x4,%eax
8010887f:	89 c2                	mov    %eax,%edx
80108881:	8b 45 98             	mov    -0x68(%ebp),%eax
80108884:	01 d0                	add    %edx,%eax
80108886:	8b 55 94             	mov    -0x6c(%ebp),%edx
80108889:	81 c2 00 00 00 80    	add    $0x80000000,%edx
8010888f:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108891:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108894:	83 c0 01             	add    $0x1,%eax
80108897:	c1 e0 04             	shl    $0x4,%eax
8010889a:	89 c2                	mov    %eax,%edx
8010889c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010889f:	01 d0                	add    %edx,%eax
801088a1:	8b 55 94             	mov    -0x6c(%ebp),%edx
801088a4:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801088aa:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801088ac:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801088b0:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801088b4:	7e a3                	jle    80108859 <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801088b6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088b9:	8b 00                	mov    (%eax),%eax
801088bb:	83 c8 02             	or     $0x2,%eax
801088be:	89 c2                	mov    %eax,%edx
801088c0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801088c3:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801088c5:	83 ec 0c             	sub    $0xc,%esp
801088c8:	68 18 c0 10 80       	push   $0x8010c018
801088cd:	e8 22 7b ff ff       	call   801003f4 <cprintf>
801088d2:	83 c4 10             	add    $0x10,%esp
}
801088d5:	90                   	nop
801088d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801088d9:	5b                   	pop    %ebx
801088da:	5e                   	pop    %esi
801088db:	5f                   	pop    %edi
801088dc:	5d                   	pop    %ebp
801088dd:	c3                   	ret

801088de <i8254_init_send>:

void i8254_init_send(){
801088de:	55                   	push   %ebp
801088df:	89 e5                	mov    %esp,%ebp
801088e1:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801088e4:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
801088e9:	05 28 38 00 00       	add    $0x3828,%eax
801088ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801088f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801088f4:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801088fa:	e8 a9 9e ff ff       	call   801027a8 <kalloc>
801088ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108902:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108907:	05 00 38 00 00       	add    $0x3800,%eax
8010890c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
8010890f:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108914:	05 04 38 00 00       	add    $0x3804,%eax
80108919:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
8010891c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108921:	05 08 38 00 00       	add    $0x3808,%eax
80108926:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
80108929:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010892c:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108932:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108935:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
80108937:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010893a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108940:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108943:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
80108949:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010894e:	05 10 38 00 00       	add    $0x3810,%eax
80108953:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108956:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
8010895b:	05 18 38 00 00       	add    $0x3818,%eax
80108960:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108963:	8b 45 d8             	mov    -0x28(%ebp),%eax
80108966:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
8010896c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010896f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108975:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108978:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010897b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108982:	e9 82 00 00 00       	jmp    80108a09 <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
80108987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010898a:	c1 e0 04             	shl    $0x4,%eax
8010898d:	89 c2                	mov    %eax,%edx
8010898f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108992:	01 d0                	add    %edx,%eax
80108994:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010899b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010899e:	c1 e0 04             	shl    $0x4,%eax
801089a1:	89 c2                	mov    %eax,%edx
801089a3:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089a6:	01 d0                	add    %edx,%eax
801089a8:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801089ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b1:	c1 e0 04             	shl    $0x4,%eax
801089b4:	89 c2                	mov    %eax,%edx
801089b6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089b9:	01 d0                	add    %edx,%eax
801089bb:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801089bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c2:	c1 e0 04             	shl    $0x4,%eax
801089c5:	89 c2                	mov    %eax,%edx
801089c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089ca:	01 d0                	add    %edx,%eax
801089cc:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801089d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d3:	c1 e0 04             	shl    $0x4,%eax
801089d6:	89 c2                	mov    %eax,%edx
801089d8:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089db:	01 d0                	add    %edx,%eax
801089dd:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801089e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e4:	c1 e0 04             	shl    $0x4,%eax
801089e7:	89 c2                	mov    %eax,%edx
801089e9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089ec:	01 d0                	add    %edx,%eax
801089ee:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801089f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f5:	c1 e0 04             	shl    $0x4,%eax
801089f8:	89 c2                	mov    %eax,%edx
801089fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
801089fd:	01 d0                	add    %edx,%eax
801089ff:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108a05:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108a09:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108a10:	0f 8e 71 ff ff ff    	jle    80108987 <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a16:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108a1d:	eb 57                	jmp    80108a76 <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108a1f:	e8 84 9d ff ff       	call   801027a8 <kalloc>
80108a24:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
80108a27:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
80108a2b:	75 12                	jne    80108a3f <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108a2d:	83 ec 0c             	sub    $0xc,%esp
80108a30:	68 f8 bf 10 80       	push   $0x8010bff8
80108a35:	e8 ba 79 ff ff       	call   801003f4 <cprintf>
80108a3a:	83 c4 10             	add    $0x10,%esp
      break;
80108a3d:	eb 3d                	jmp    80108a7c <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a42:	c1 e0 04             	shl    $0x4,%eax
80108a45:	89 c2                	mov    %eax,%edx
80108a47:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a4a:	01 d0                	add    %edx,%eax
80108a4c:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a4f:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108a55:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a5a:	83 c0 01             	add    $0x1,%eax
80108a5d:	c1 e0 04             	shl    $0x4,%eax
80108a60:	89 c2                	mov    %eax,%edx
80108a62:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108a65:	01 d0                	add    %edx,%eax
80108a67:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108a6a:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108a70:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108a72:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108a76:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80108a7a:	7e a3                	jle    80108a1f <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108a7c:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a81:	05 00 04 00 00       	add    $0x400,%eax
80108a86:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
80108a89:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108a8c:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108a92:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108a97:	05 10 04 00 00       	add    $0x410,%eax
80108a9c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
80108a9f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80108aa2:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
80108aa8:	83 ec 0c             	sub    $0xc,%esp
80108aab:	68 38 c0 10 80       	push   $0x8010c038
80108ab0:	e8 3f 79 ff ff       	call   801003f4 <cprintf>
80108ab5:	83 c4 10             	add    $0x10,%esp

}
80108ab8:	90                   	nop
80108ab9:	c9                   	leave
80108aba:	c3                   	ret

80108abb <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
80108abb:	55                   	push   %ebp
80108abc:	89 e5                	mov    %esp,%ebp
80108abe:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
80108ac1:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108ac6:	83 c0 14             	add    $0x14,%eax
80108ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
80108acc:	8b 45 08             	mov    0x8(%ebp),%eax
80108acf:	c1 e0 08             	shl    $0x8,%eax
80108ad2:	0f b7 c0             	movzwl %ax,%eax
80108ad5:	83 c8 01             	or     $0x1,%eax
80108ad8:	89 c2                	mov    %eax,%edx
80108ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108add:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
80108adf:	83 ec 0c             	sub    $0xc,%esp
80108ae2:	68 58 c0 10 80       	push   $0x8010c058
80108ae7:	e8 08 79 ff ff       	call   801003f4 <cprintf>
80108aec:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
80108aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af2:	8b 00                	mov    (%eax),%eax
80108af4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
80108af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108afa:	83 e0 10             	and    $0x10,%eax
80108afd:	85 c0                	test   %eax,%eax
80108aff:	75 02                	jne    80108b03 <i8254_read_eeprom+0x48>
  while(1){
80108b01:	eb dc                	jmp    80108adf <i8254_read_eeprom+0x24>
      break;
80108b03:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b07:	8b 00                	mov    (%eax),%eax
80108b09:	c1 e8 10             	shr    $0x10,%eax
}
80108b0c:	c9                   	leave
80108b0d:	c3                   	ret

80108b0e <i8254_recv>:
void i8254_recv(){
80108b0e:	55                   	push   %ebp
80108b0f:	89 e5                	mov    %esp,%ebp
80108b11:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108b14:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b19:	05 10 28 00 00       	add    $0x2810,%eax
80108b1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108b21:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b26:	05 18 28 00 00       	add    $0x2818,%eax
80108b2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108b2e:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108b33:	05 00 28 00 00       	add    $0x2800,%eax
80108b38:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108b3e:	8b 00                	mov    (%eax),%eax
80108b40:	05 00 00 00 80       	add    $0x80000000,%eax
80108b45:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b4b:	8b 10                	mov    (%eax),%edx
80108b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b50:	8b 00                	mov    (%eax),%eax
80108b52:	29 c2                	sub    %eax,%edx
80108b54:	89 d0                	mov    %edx,%eax
80108b56:	25 ff 00 00 00       	and    $0xff,%eax
80108b5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108b5e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b62:	7e 37                	jle    80108b9b <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b67:	8b 00                	mov    (%eax),%eax
80108b69:	c1 e0 04             	shl    $0x4,%eax
80108b6c:	89 c2                	mov    %eax,%edx
80108b6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b71:	01 d0                	add    %edx,%eax
80108b73:	8b 00                	mov    (%eax),%eax
80108b75:	05 00 00 00 80       	add    $0x80000000,%eax
80108b7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b80:	8b 00                	mov    (%eax),%eax
80108b82:	83 c0 01             	add    $0x1,%eax
80108b85:	0f b6 d0             	movzbl %al,%edx
80108b88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b8b:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108b8d:	83 ec 0c             	sub    $0xc,%esp
80108b90:	ff 75 e0             	push   -0x20(%ebp)
80108b93:	e8 13 09 00 00       	call   801094ab <eth_proc>
80108b98:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b9e:	8b 10                	mov    (%eax),%edx
80108ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba3:	8b 00                	mov    (%eax),%eax
80108ba5:	39 c2                	cmp    %eax,%edx
80108ba7:	75 9f                	jne    80108b48 <i8254_recv+0x3a>
      (*rdt)--;
80108ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bac:	8b 00                	mov    (%eax),%eax
80108bae:	8d 50 ff             	lea    -0x1(%eax),%edx
80108bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bb4:	89 10                	mov    %edx,(%eax)
  while(1){
80108bb6:	eb 90                	jmp    80108b48 <i8254_recv+0x3a>

80108bb8 <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108bb8:	55                   	push   %ebp
80108bb9:	89 e5                	mov    %esp,%ebp
80108bbb:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108bbe:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bc3:	05 10 38 00 00       	add    $0x3810,%eax
80108bc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108bcb:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bd0:	05 18 38 00 00       	add    $0x3818,%eax
80108bd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108bd8:	a1 7c 6c 19 80       	mov    0x80196c7c,%eax
80108bdd:	05 00 38 00 00       	add    $0x3800,%eax
80108be2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108be8:	8b 00                	mov    (%eax),%eax
80108bea:	05 00 00 00 80       	add    $0x80000000,%eax
80108bef:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108bf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bf5:	8b 10                	mov    (%eax),%edx
80108bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bfa:	8b 00                	mov    (%eax),%eax
80108bfc:	29 c2                	sub    %eax,%edx
80108bfe:	0f b6 c2             	movzbl %dl,%eax
80108c01:	ba 00 01 00 00       	mov    $0x100,%edx
80108c06:	29 c2                	sub    %eax,%edx
80108c08:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c0e:	8b 00                	mov    (%eax),%eax
80108c10:	25 ff 00 00 00       	and    $0xff,%eax
80108c15:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108c18:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108c1c:	0f 8e a8 00 00 00    	jle    80108cca <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108c22:	8b 45 08             	mov    0x8(%ebp),%eax
80108c25:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108c28:	89 d1                	mov    %edx,%ecx
80108c2a:	c1 e1 04             	shl    $0x4,%ecx
80108c2d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108c30:	01 ca                	add    %ecx,%edx
80108c32:	8b 12                	mov    (%edx),%edx
80108c34:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108c3a:	83 ec 04             	sub    $0x4,%esp
80108c3d:	ff 75 0c             	push   0xc(%ebp)
80108c40:	50                   	push   %eax
80108c41:	52                   	push   %edx
80108c42:	e8 f9 be ff ff       	call   80104b40 <memmove>
80108c47:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108c4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c4d:	c1 e0 04             	shl    $0x4,%eax
80108c50:	89 c2                	mov    %eax,%edx
80108c52:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c55:	01 d0                	add    %edx,%eax
80108c57:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c5a:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108c5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c61:	c1 e0 04             	shl    $0x4,%eax
80108c64:	89 c2                	mov    %eax,%edx
80108c66:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c69:	01 d0                	add    %edx,%eax
80108c6b:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108c6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c72:	c1 e0 04             	shl    $0x4,%eax
80108c75:	89 c2                	mov    %eax,%edx
80108c77:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c7a:	01 d0                	add    %edx,%eax
80108c7c:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108c80:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c83:	c1 e0 04             	shl    $0x4,%eax
80108c86:	89 c2                	mov    %eax,%edx
80108c88:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c8b:	01 d0                	add    %edx,%eax
80108c8d:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108c91:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c94:	c1 e0 04             	shl    $0x4,%eax
80108c97:	89 c2                	mov    %eax,%edx
80108c99:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c9c:	01 d0                	add    %edx,%eax
80108c9e:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108ca4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108ca7:	c1 e0 04             	shl    $0x4,%eax
80108caa:	89 c2                	mov    %eax,%edx
80108cac:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108caf:	01 d0                	add    %edx,%eax
80108cb1:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cb8:	8b 00                	mov    (%eax),%eax
80108cba:	83 c0 01             	add    $0x1,%eax
80108cbd:	0f b6 d0             	movzbl %al,%edx
80108cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cc3:	89 10                	mov    %edx,(%eax)
    return len;
80108cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cc8:	eb 05                	jmp    80108ccf <i8254_send+0x117>
  }else{
    return -1;
80108cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108ccf:	c9                   	leave
80108cd0:	c3                   	ret

80108cd1 <i8254_intr>:

void i8254_intr(){
80108cd1:	55                   	push   %ebp
80108cd2:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108cd4:	a1 88 6c 19 80       	mov    0x80196c88,%eax
80108cd9:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108cdf:	90                   	nop
80108ce0:	5d                   	pop    %ebp
80108ce1:	c3                   	ret

80108ce2 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108ce2:	55                   	push   %ebp
80108ce3:	89 e5                	mov    %esp,%ebp
80108ce5:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108ce8:	8b 45 08             	mov    0x8(%ebp),%eax
80108ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf1:	0f b7 00             	movzwl (%eax),%eax
80108cf4:	66 3d 00 01          	cmp    $0x100,%ax
80108cf8:	74 0a                	je     80108d04 <arp_proc+0x22>
80108cfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108cff:	e9 4f 01 00 00       	jmp    80108e53 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d07:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108d0b:	66 83 f8 08          	cmp    $0x8,%ax
80108d0f:	74 0a                	je     80108d1b <arp_proc+0x39>
80108d11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d16:	e9 38 01 00 00       	jmp    80108e53 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108d22:	3c 06                	cmp    $0x6,%al
80108d24:	74 0a                	je     80108d30 <arp_proc+0x4e>
80108d26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d2b:	e9 23 01 00 00       	jmp    80108e53 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d33:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108d37:	3c 04                	cmp    $0x4,%al
80108d39:	74 0a                	je     80108d45 <arp_proc+0x63>
80108d3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d40:	e9 0e 01 00 00       	jmp    80108e53 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d48:	83 c0 18             	add    $0x18,%eax
80108d4b:	83 ec 04             	sub    $0x4,%esp
80108d4e:	6a 04                	push   $0x4
80108d50:	50                   	push   %eax
80108d51:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d56:	e8 8d bd ff ff       	call   80104ae8 <memcmp>
80108d5b:	83 c4 10             	add    $0x10,%esp
80108d5e:	85 c0                	test   %eax,%eax
80108d60:	74 27                	je     80108d89 <arp_proc+0xa7>
80108d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d65:	83 c0 0e             	add    $0xe,%eax
80108d68:	83 ec 04             	sub    $0x4,%esp
80108d6b:	6a 04                	push   $0x4
80108d6d:	50                   	push   %eax
80108d6e:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d73:	e8 70 bd ff ff       	call   80104ae8 <memcmp>
80108d78:	83 c4 10             	add    $0x10,%esp
80108d7b:	85 c0                	test   %eax,%eax
80108d7d:	74 0a                	je     80108d89 <arp_proc+0xa7>
80108d7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d84:	e9 ca 00 00 00       	jmp    80108e53 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108d89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d8c:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108d90:	66 3d 00 01          	cmp    $0x100,%ax
80108d94:	75 69                	jne    80108dff <arp_proc+0x11d>
80108d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d99:	83 c0 18             	add    $0x18,%eax
80108d9c:	83 ec 04             	sub    $0x4,%esp
80108d9f:	6a 04                	push   $0x4
80108da1:	50                   	push   %eax
80108da2:	68 e4 f4 10 80       	push   $0x8010f4e4
80108da7:	e8 3c bd ff ff       	call   80104ae8 <memcmp>
80108dac:	83 c4 10             	add    $0x10,%esp
80108daf:	85 c0                	test   %eax,%eax
80108db1:	75 4c                	jne    80108dff <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108db3:	e8 f0 99 ff ff       	call   801027a8 <kalloc>
80108db8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108dbb:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108dc2:	83 ec 04             	sub    $0x4,%esp
80108dc5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108dc8:	50                   	push   %eax
80108dc9:	ff 75 f0             	push   -0x10(%ebp)
80108dcc:	ff 75 f4             	push   -0xc(%ebp)
80108dcf:	e8 1f 04 00 00       	call   801091f3 <arp_reply_pkt_create>
80108dd4:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108dd7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dda:	83 ec 08             	sub    $0x8,%esp
80108ddd:	50                   	push   %eax
80108dde:	ff 75 f0             	push   -0x10(%ebp)
80108de1:	e8 d2 fd ff ff       	call   80108bb8 <i8254_send>
80108de6:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dec:	83 ec 0c             	sub    $0xc,%esp
80108def:	50                   	push   %eax
80108df0:	e8 19 99 ff ff       	call   8010270e <kfree>
80108df5:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108df8:	b8 02 00 00 00       	mov    $0x2,%eax
80108dfd:	eb 54                	jmp    80108e53 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e02:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108e06:	66 3d 00 02          	cmp    $0x200,%ax
80108e0a:	75 42                	jne    80108e4e <arp_proc+0x16c>
80108e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e0f:	83 c0 18             	add    $0x18,%eax
80108e12:	83 ec 04             	sub    $0x4,%esp
80108e15:	6a 04                	push   $0x4
80108e17:	50                   	push   %eax
80108e18:	68 e4 f4 10 80       	push   $0x8010f4e4
80108e1d:	e8 c6 bc ff ff       	call   80104ae8 <memcmp>
80108e22:	83 c4 10             	add    $0x10,%esp
80108e25:	85 c0                	test   %eax,%eax
80108e27:	75 25                	jne    80108e4e <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108e29:	83 ec 0c             	sub    $0xc,%esp
80108e2c:	68 5c c0 10 80       	push   $0x8010c05c
80108e31:	e8 be 75 ff ff       	call   801003f4 <cprintf>
80108e36:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108e39:	83 ec 0c             	sub    $0xc,%esp
80108e3c:	ff 75 f4             	push   -0xc(%ebp)
80108e3f:	e8 af 01 00 00       	call   80108ff3 <arp_table_update>
80108e44:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108e47:	b8 01 00 00 00       	mov    $0x1,%eax
80108e4c:	eb 05                	jmp    80108e53 <arp_proc+0x171>
  }else{
    return -1;
80108e4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108e53:	c9                   	leave
80108e54:	c3                   	ret

80108e55 <arp_scan>:

void arp_scan(){
80108e55:	55                   	push   %ebp
80108e56:	89 e5                	mov    %esp,%ebp
80108e58:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108e5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e62:	eb 6f                	jmp    80108ed3 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108e64:	e8 3f 99 ff ff       	call   801027a8 <kalloc>
80108e69:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108e6c:	83 ec 04             	sub    $0x4,%esp
80108e6f:	ff 75 f4             	push   -0xc(%ebp)
80108e72:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108e75:	50                   	push   %eax
80108e76:	ff 75 ec             	push   -0x14(%ebp)
80108e79:	e8 62 00 00 00       	call   80108ee0 <arp_broadcast>
80108e7e:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108e81:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e84:	83 ec 08             	sub    $0x8,%esp
80108e87:	50                   	push   %eax
80108e88:	ff 75 ec             	push   -0x14(%ebp)
80108e8b:	e8 28 fd ff ff       	call   80108bb8 <i8254_send>
80108e90:	83 c4 10             	add    $0x10,%esp
80108e93:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108e96:	eb 22                	jmp    80108eba <arp_scan+0x65>
      microdelay(1);
80108e98:	83 ec 0c             	sub    $0xc,%esp
80108e9b:	6a 01                	push   $0x1
80108e9d:	e8 97 9c ff ff       	call   80102b39 <microdelay>
80108ea2:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108ea5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ea8:	83 ec 08             	sub    $0x8,%esp
80108eab:	50                   	push   %eax
80108eac:	ff 75 ec             	push   -0x14(%ebp)
80108eaf:	e8 04 fd ff ff       	call   80108bb8 <i8254_send>
80108eb4:	83 c4 10             	add    $0x10,%esp
80108eb7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108eba:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108ebe:	74 d8                	je     80108e98 <arp_scan+0x43>
    }
    kfree((char *)send);
80108ec0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ec3:	83 ec 0c             	sub    $0xc,%esp
80108ec6:	50                   	push   %eax
80108ec7:	e8 42 98 ff ff       	call   8010270e <kfree>
80108ecc:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108ecf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108ed3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108eda:	7e 88                	jle    80108e64 <arp_scan+0xf>
  }
}
80108edc:	90                   	nop
80108edd:	90                   	nop
80108ede:	c9                   	leave
80108edf:	c3                   	ret

80108ee0 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108ee0:	55                   	push   %ebp
80108ee1:	89 e5                	mov    %esp,%ebp
80108ee3:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108ee6:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108eea:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108eee:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108ef2:	8b 45 10             	mov    0x10(%ebp),%eax
80108ef5:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108ef8:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108eff:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108f05:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108f0c:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108f12:	8b 45 0c             	mov    0xc(%ebp),%eax
80108f15:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108f1b:	8b 45 08             	mov    0x8(%ebp),%eax
80108f1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108f21:	8b 45 08             	mov    0x8(%ebp),%eax
80108f24:	83 c0 0e             	add    $0xe,%eax
80108f27:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f2d:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f34:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f3b:	83 ec 04             	sub    $0x4,%esp
80108f3e:	6a 06                	push   $0x6
80108f40:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108f43:	52                   	push   %edx
80108f44:	50                   	push   %eax
80108f45:	e8 f6 bb ff ff       	call   80104b40 <memmove>
80108f4a:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f50:	83 c0 06             	add    $0x6,%eax
80108f53:	83 ec 04             	sub    $0x4,%esp
80108f56:	6a 06                	push   $0x6
80108f58:	68 80 6c 19 80       	push   $0x80196c80
80108f5d:	50                   	push   %eax
80108f5e:	e8 dd bb ff ff       	call   80104b40 <memmove>
80108f63:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f69:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108f6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f71:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f7a:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f81:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108f85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f88:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f91:	8d 50 12             	lea    0x12(%eax),%edx
80108f94:	83 ec 04             	sub    $0x4,%esp
80108f97:	6a 06                	push   $0x6
80108f99:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108f9c:	50                   	push   %eax
80108f9d:	52                   	push   %edx
80108f9e:	e8 9d bb ff ff       	call   80104b40 <memmove>
80108fa3:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fa9:	8d 50 18             	lea    0x18(%eax),%edx
80108fac:	83 ec 04             	sub    $0x4,%esp
80108faf:	6a 04                	push   $0x4
80108fb1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108fb4:	50                   	push   %eax
80108fb5:	52                   	push   %edx
80108fb6:	e8 85 bb ff ff       	call   80104b40 <memmove>
80108fbb:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108fbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc1:	83 c0 08             	add    $0x8,%eax
80108fc4:	83 ec 04             	sub    $0x4,%esp
80108fc7:	6a 06                	push   $0x6
80108fc9:	68 80 6c 19 80       	push   $0x80196c80
80108fce:	50                   	push   %eax
80108fcf:	e8 6c bb ff ff       	call   80104b40 <memmove>
80108fd4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108fd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fda:	83 c0 0e             	add    $0xe,%eax
80108fdd:	83 ec 04             	sub    $0x4,%esp
80108fe0:	6a 04                	push   $0x4
80108fe2:	68 e4 f4 10 80       	push   $0x8010f4e4
80108fe7:	50                   	push   %eax
80108fe8:	e8 53 bb ff ff       	call   80104b40 <memmove>
80108fed:	83 c4 10             	add    $0x10,%esp
}
80108ff0:	90                   	nop
80108ff1:	c9                   	leave
80108ff2:	c3                   	ret

80108ff3 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108ff3:	55                   	push   %ebp
80108ff4:	89 e5                	mov    %esp,%ebp
80108ff6:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80108ffc:	83 c0 0e             	add    $0xe,%eax
80108fff:	83 ec 0c             	sub    $0xc,%esp
80109002:	50                   	push   %eax
80109003:	e8 bc 00 00 00       	call   801090c4 <arp_table_search>
80109008:	83 c4 10             	add    $0x10,%esp
8010900b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
8010900e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80109012:	78 2d                	js     80109041 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109014:	8b 45 08             	mov    0x8(%ebp),%eax
80109017:	8d 48 08             	lea    0x8(%eax),%ecx
8010901a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010901d:	89 d0                	mov    %edx,%eax
8010901f:	c1 e0 02             	shl    $0x2,%eax
80109022:	01 d0                	add    %edx,%eax
80109024:	01 c0                	add    %eax,%eax
80109026:	01 d0                	add    %edx,%eax
80109028:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010902d:	83 c0 04             	add    $0x4,%eax
80109030:	83 ec 04             	sub    $0x4,%esp
80109033:	6a 06                	push   $0x6
80109035:	51                   	push   %ecx
80109036:	50                   	push   %eax
80109037:	e8 04 bb ff ff       	call   80104b40 <memmove>
8010903c:	83 c4 10             	add    $0x10,%esp
8010903f:	eb 70                	jmp    801090b1 <arp_table_update+0xbe>
  }else{
    index += 1;
80109041:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80109045:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80109048:	8b 45 08             	mov    0x8(%ebp),%eax
8010904b:	8d 48 08             	lea    0x8(%eax),%ecx
8010904e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109051:	89 d0                	mov    %edx,%eax
80109053:	c1 e0 02             	shl    $0x2,%eax
80109056:	01 d0                	add    %edx,%eax
80109058:	01 c0                	add    %eax,%eax
8010905a:	01 d0                	add    %edx,%eax
8010905c:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109061:	83 c0 04             	add    $0x4,%eax
80109064:	83 ec 04             	sub    $0x4,%esp
80109067:	6a 06                	push   $0x6
80109069:	51                   	push   %ecx
8010906a:	50                   	push   %eax
8010906b:	e8 d0 ba ff ff       	call   80104b40 <memmove>
80109070:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80109073:	8b 45 08             	mov    0x8(%ebp),%eax
80109076:	8d 48 0e             	lea    0xe(%eax),%ecx
80109079:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010907c:	89 d0                	mov    %edx,%eax
8010907e:	c1 e0 02             	shl    $0x2,%eax
80109081:	01 d0                	add    %edx,%eax
80109083:	01 c0                	add    %eax,%eax
80109085:	01 d0                	add    %edx,%eax
80109087:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
8010908c:	83 ec 04             	sub    $0x4,%esp
8010908f:	6a 04                	push   $0x4
80109091:	51                   	push   %ecx
80109092:	50                   	push   %eax
80109093:	e8 a8 ba ff ff       	call   80104b40 <memmove>
80109098:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
8010909b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010909e:	89 d0                	mov    %edx,%eax
801090a0:	c1 e0 02             	shl    $0x2,%eax
801090a3:	01 d0                	add    %edx,%eax
801090a5:	01 c0                	add    %eax,%eax
801090a7:	01 d0                	add    %edx,%eax
801090a9:	05 aa 6c 19 80       	add    $0x80196caa,%eax
801090ae:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
801090b1:	83 ec 0c             	sub    $0xc,%esp
801090b4:	68 a0 6c 19 80       	push   $0x80196ca0
801090b9:	e8 83 00 00 00       	call   80109141 <print_arp_table>
801090be:	83 c4 10             	add    $0x10,%esp
}
801090c1:	90                   	nop
801090c2:	c9                   	leave
801090c3:	c3                   	ret

801090c4 <arp_table_search>:

int arp_table_search(uchar *ip){
801090c4:	55                   	push   %ebp
801090c5:	89 e5                	mov    %esp,%ebp
801090c7:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
801090ca:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
801090d1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801090d8:	eb 59                	jmp    80109133 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
801090da:	8b 55 f0             	mov    -0x10(%ebp),%edx
801090dd:	89 d0                	mov    %edx,%eax
801090df:	c1 e0 02             	shl    $0x2,%eax
801090e2:	01 d0                	add    %edx,%eax
801090e4:	01 c0                	add    %eax,%eax
801090e6:	01 d0                	add    %edx,%eax
801090e8:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801090ed:	83 ec 04             	sub    $0x4,%esp
801090f0:	6a 04                	push   $0x4
801090f2:	ff 75 08             	push   0x8(%ebp)
801090f5:	50                   	push   %eax
801090f6:	e8 ed b9 ff ff       	call   80104ae8 <memcmp>
801090fb:	83 c4 10             	add    $0x10,%esp
801090fe:	85 c0                	test   %eax,%eax
80109100:	75 05                	jne    80109107 <arp_table_search+0x43>
      return i;
80109102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109105:	eb 38                	jmp    8010913f <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
80109107:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010910a:	89 d0                	mov    %edx,%eax
8010910c:	c1 e0 02             	shl    $0x2,%eax
8010910f:	01 d0                	add    %edx,%eax
80109111:	01 c0                	add    %eax,%eax
80109113:	01 d0                	add    %edx,%eax
80109115:	05 aa 6c 19 80       	add    $0x80196caa,%eax
8010911a:	0f b6 00             	movzbl (%eax),%eax
8010911d:	84 c0                	test   %al,%al
8010911f:	75 0e                	jne    8010912f <arp_table_search+0x6b>
80109121:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109125:	75 08                	jne    8010912f <arp_table_search+0x6b>
      empty = -i;
80109127:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010912a:	f7 d8                	neg    %eax
8010912c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
8010912f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109133:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
80109137:	7e a1                	jle    801090da <arp_table_search+0x16>
    }
  }
  return empty-1;
80109139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913c:	83 e8 01             	sub    $0x1,%eax
}
8010913f:	c9                   	leave
80109140:	c3                   	ret

80109141 <print_arp_table>:

void print_arp_table(){
80109141:	55                   	push   %ebp
80109142:	89 e5                	mov    %esp,%ebp
80109144:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
80109147:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010914e:	e9 92 00 00 00       	jmp    801091e5 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109153:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109156:	89 d0                	mov    %edx,%eax
80109158:	c1 e0 02             	shl    $0x2,%eax
8010915b:	01 d0                	add    %edx,%eax
8010915d:	01 c0                	add    %eax,%eax
8010915f:	01 d0                	add    %edx,%eax
80109161:	05 aa 6c 19 80       	add    $0x80196caa,%eax
80109166:	0f b6 00             	movzbl (%eax),%eax
80109169:	84 c0                	test   %al,%al
8010916b:	74 74                	je     801091e1 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
8010916d:	83 ec 08             	sub    $0x8,%esp
80109170:	ff 75 f4             	push   -0xc(%ebp)
80109173:	68 6f c0 10 80       	push   $0x8010c06f
80109178:	e8 77 72 ff ff       	call   801003f4 <cprintf>
8010917d:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109180:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109183:	89 d0                	mov    %edx,%eax
80109185:	c1 e0 02             	shl    $0x2,%eax
80109188:	01 d0                	add    %edx,%eax
8010918a:	01 c0                	add    %eax,%eax
8010918c:	01 d0                	add    %edx,%eax
8010918e:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
80109193:	83 ec 0c             	sub    $0xc,%esp
80109196:	50                   	push   %eax
80109197:	e8 54 02 00 00       	call   801093f0 <print_ipv4>
8010919c:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
8010919f:	83 ec 0c             	sub    $0xc,%esp
801091a2:	68 7e c0 10 80       	push   $0x8010c07e
801091a7:	e8 48 72 ff ff       	call   801003f4 <cprintf>
801091ac:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801091af:	8b 55 f4             	mov    -0xc(%ebp),%edx
801091b2:	89 d0                	mov    %edx,%eax
801091b4:	c1 e0 02             	shl    $0x2,%eax
801091b7:	01 d0                	add    %edx,%eax
801091b9:	01 c0                	add    %eax,%eax
801091bb:	01 d0                	add    %edx,%eax
801091bd:	05 a0 6c 19 80       	add    $0x80196ca0,%eax
801091c2:	83 c0 04             	add    $0x4,%eax
801091c5:	83 ec 0c             	sub    $0xc,%esp
801091c8:	50                   	push   %eax
801091c9:	e8 70 02 00 00       	call   8010943e <print_mac>
801091ce:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801091d1:	83 ec 0c             	sub    $0xc,%esp
801091d4:	68 80 c0 10 80       	push   $0x8010c080
801091d9:	e8 16 72 ff ff       	call   801003f4 <cprintf>
801091de:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801091e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801091e5:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801091e9:	0f 8e 64 ff ff ff    	jle    80109153 <print_arp_table+0x12>
    }
  }
}
801091ef:	90                   	nop
801091f0:	90                   	nop
801091f1:	c9                   	leave
801091f2:	c3                   	ret

801091f3 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801091f3:	55                   	push   %ebp
801091f4:	89 e5                	mov    %esp,%ebp
801091f6:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801091f9:	8b 45 10             	mov    0x10(%ebp),%eax
801091fc:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109202:	8b 45 0c             	mov    0xc(%ebp),%eax
80109205:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80109208:	8b 45 0c             	mov    0xc(%ebp),%eax
8010920b:	83 c0 0e             	add    $0xe,%eax
8010920e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109211:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109214:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80109218:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010921b:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
8010921f:	8b 45 08             	mov    0x8(%ebp),%eax
80109222:	8d 50 08             	lea    0x8(%eax),%edx
80109225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109228:	83 ec 04             	sub    $0x4,%esp
8010922b:	6a 06                	push   $0x6
8010922d:	52                   	push   %edx
8010922e:	50                   	push   %eax
8010922f:	e8 0c b9 ff ff       	call   80104b40 <memmove>
80109234:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80109237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010923a:	83 c0 06             	add    $0x6,%eax
8010923d:	83 ec 04             	sub    $0x4,%esp
80109240:	6a 06                	push   $0x6
80109242:	68 80 6c 19 80       	push   $0x80196c80
80109247:	50                   	push   %eax
80109248:	e8 f3 b8 ff ff       	call   80104b40 <memmove>
8010924d:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109250:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109253:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80109258:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010925b:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109261:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109264:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80109268:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010926b:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
8010926f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109272:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
80109278:	8b 45 08             	mov    0x8(%ebp),%eax
8010927b:	8d 50 08             	lea    0x8(%eax),%edx
8010927e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109281:	83 c0 12             	add    $0x12,%eax
80109284:	83 ec 04             	sub    $0x4,%esp
80109287:	6a 06                	push   $0x6
80109289:	52                   	push   %edx
8010928a:	50                   	push   %eax
8010928b:	e8 b0 b8 ff ff       	call   80104b40 <memmove>
80109290:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109293:	8b 45 08             	mov    0x8(%ebp),%eax
80109296:	8d 50 0e             	lea    0xe(%eax),%edx
80109299:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010929c:	83 c0 18             	add    $0x18,%eax
8010929f:	83 ec 04             	sub    $0x4,%esp
801092a2:	6a 04                	push   $0x4
801092a4:	52                   	push   %edx
801092a5:	50                   	push   %eax
801092a6:	e8 95 b8 ff ff       	call   80104b40 <memmove>
801092ab:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801092ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092b1:	83 c0 08             	add    $0x8,%eax
801092b4:	83 ec 04             	sub    $0x4,%esp
801092b7:	6a 06                	push   $0x6
801092b9:	68 80 6c 19 80       	push   $0x80196c80
801092be:	50                   	push   %eax
801092bf:	e8 7c b8 ff ff       	call   80104b40 <memmove>
801092c4:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801092c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801092ca:	83 c0 0e             	add    $0xe,%eax
801092cd:	83 ec 04             	sub    $0x4,%esp
801092d0:	6a 04                	push   $0x4
801092d2:	68 e4 f4 10 80       	push   $0x8010f4e4
801092d7:	50                   	push   %eax
801092d8:	e8 63 b8 ff ff       	call   80104b40 <memmove>
801092dd:	83 c4 10             	add    $0x10,%esp
}
801092e0:	90                   	nop
801092e1:	c9                   	leave
801092e2:	c3                   	ret

801092e3 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801092e3:	55                   	push   %ebp
801092e4:	89 e5                	mov    %esp,%ebp
801092e6:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801092e9:	83 ec 0c             	sub    $0xc,%esp
801092ec:	68 82 c0 10 80       	push   $0x8010c082
801092f1:	e8 fe 70 ff ff       	call   801003f4 <cprintf>
801092f6:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801092f9:	8b 45 08             	mov    0x8(%ebp),%eax
801092fc:	83 c0 0e             	add    $0xe,%eax
801092ff:	83 ec 0c             	sub    $0xc,%esp
80109302:	50                   	push   %eax
80109303:	e8 e8 00 00 00       	call   801093f0 <print_ipv4>
80109308:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010930b:	83 ec 0c             	sub    $0xc,%esp
8010930e:	68 80 c0 10 80       	push   $0x8010c080
80109313:	e8 dc 70 ff ff       	call   801003f4 <cprintf>
80109318:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010931b:	8b 45 08             	mov    0x8(%ebp),%eax
8010931e:	83 c0 08             	add    $0x8,%eax
80109321:	83 ec 0c             	sub    $0xc,%esp
80109324:	50                   	push   %eax
80109325:	e8 14 01 00 00       	call   8010943e <print_mac>
8010932a:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010932d:	83 ec 0c             	sub    $0xc,%esp
80109330:	68 80 c0 10 80       	push   $0x8010c080
80109335:	e8 ba 70 ff ff       	call   801003f4 <cprintf>
8010933a:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
8010933d:	83 ec 0c             	sub    $0xc,%esp
80109340:	68 99 c0 10 80       	push   $0x8010c099
80109345:	e8 aa 70 ff ff       	call   801003f4 <cprintf>
8010934a:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
8010934d:	8b 45 08             	mov    0x8(%ebp),%eax
80109350:	83 c0 18             	add    $0x18,%eax
80109353:	83 ec 0c             	sub    $0xc,%esp
80109356:	50                   	push   %eax
80109357:	e8 94 00 00 00       	call   801093f0 <print_ipv4>
8010935c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010935f:	83 ec 0c             	sub    $0xc,%esp
80109362:	68 80 c0 10 80       	push   $0x8010c080
80109367:	e8 88 70 ff ff       	call   801003f4 <cprintf>
8010936c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
8010936f:	8b 45 08             	mov    0x8(%ebp),%eax
80109372:	83 c0 12             	add    $0x12,%eax
80109375:	83 ec 0c             	sub    $0xc,%esp
80109378:	50                   	push   %eax
80109379:	e8 c0 00 00 00       	call   8010943e <print_mac>
8010937e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109381:	83 ec 0c             	sub    $0xc,%esp
80109384:	68 80 c0 10 80       	push   $0x8010c080
80109389:	e8 66 70 ff ff       	call   801003f4 <cprintf>
8010938e:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109391:	83 ec 0c             	sub    $0xc,%esp
80109394:	68 b0 c0 10 80       	push   $0x8010c0b0
80109399:	e8 56 70 ff ff       	call   801003f4 <cprintf>
8010939e:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801093a1:	8b 45 08             	mov    0x8(%ebp),%eax
801093a4:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093a8:	66 3d 00 01          	cmp    $0x100,%ax
801093ac:	75 12                	jne    801093c0 <print_arp_info+0xdd>
801093ae:	83 ec 0c             	sub    $0xc,%esp
801093b1:	68 bc c0 10 80       	push   $0x8010c0bc
801093b6:	e8 39 70 ff ff       	call   801003f4 <cprintf>
801093bb:	83 c4 10             	add    $0x10,%esp
801093be:	eb 1d                	jmp    801093dd <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801093c0:	8b 45 08             	mov    0x8(%ebp),%eax
801093c3:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801093c7:	66 3d 00 02          	cmp    $0x200,%ax
801093cb:	75 10                	jne    801093dd <print_arp_info+0xfa>
    cprintf("Reply\n");
801093cd:	83 ec 0c             	sub    $0xc,%esp
801093d0:	68 c5 c0 10 80       	push   $0x8010c0c5
801093d5:	e8 1a 70 ff ff       	call   801003f4 <cprintf>
801093da:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801093dd:	83 ec 0c             	sub    $0xc,%esp
801093e0:	68 80 c0 10 80       	push   $0x8010c080
801093e5:	e8 0a 70 ff ff       	call   801003f4 <cprintf>
801093ea:	83 c4 10             	add    $0x10,%esp
}
801093ed:	90                   	nop
801093ee:	c9                   	leave
801093ef:	c3                   	ret

801093f0 <print_ipv4>:

void print_ipv4(uchar *ip){
801093f0:	55                   	push   %ebp
801093f1:	89 e5                	mov    %esp,%ebp
801093f3:	53                   	push   %ebx
801093f4:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801093f7:	8b 45 08             	mov    0x8(%ebp),%eax
801093fa:	83 c0 03             	add    $0x3,%eax
801093fd:	0f b6 00             	movzbl (%eax),%eax
80109400:	0f b6 d8             	movzbl %al,%ebx
80109403:	8b 45 08             	mov    0x8(%ebp),%eax
80109406:	83 c0 02             	add    $0x2,%eax
80109409:	0f b6 00             	movzbl (%eax),%eax
8010940c:	0f b6 c8             	movzbl %al,%ecx
8010940f:	8b 45 08             	mov    0x8(%ebp),%eax
80109412:	83 c0 01             	add    $0x1,%eax
80109415:	0f b6 00             	movzbl (%eax),%eax
80109418:	0f b6 d0             	movzbl %al,%edx
8010941b:	8b 45 08             	mov    0x8(%ebp),%eax
8010941e:	0f b6 00             	movzbl (%eax),%eax
80109421:	0f b6 c0             	movzbl %al,%eax
80109424:	83 ec 0c             	sub    $0xc,%esp
80109427:	53                   	push   %ebx
80109428:	51                   	push   %ecx
80109429:	52                   	push   %edx
8010942a:	50                   	push   %eax
8010942b:	68 cc c0 10 80       	push   $0x8010c0cc
80109430:	e8 bf 6f ff ff       	call   801003f4 <cprintf>
80109435:	83 c4 20             	add    $0x20,%esp
}
80109438:	90                   	nop
80109439:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010943c:	c9                   	leave
8010943d:	c3                   	ret

8010943e <print_mac>:

void print_mac(uchar *mac){
8010943e:	55                   	push   %ebp
8010943f:	89 e5                	mov    %esp,%ebp
80109441:	57                   	push   %edi
80109442:	56                   	push   %esi
80109443:	53                   	push   %ebx
80109444:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
80109447:	8b 45 08             	mov    0x8(%ebp),%eax
8010944a:	83 c0 05             	add    $0x5,%eax
8010944d:	0f b6 00             	movzbl (%eax),%eax
80109450:	0f b6 f8             	movzbl %al,%edi
80109453:	8b 45 08             	mov    0x8(%ebp),%eax
80109456:	83 c0 04             	add    $0x4,%eax
80109459:	0f b6 00             	movzbl (%eax),%eax
8010945c:	0f b6 f0             	movzbl %al,%esi
8010945f:	8b 45 08             	mov    0x8(%ebp),%eax
80109462:	83 c0 03             	add    $0x3,%eax
80109465:	0f b6 00             	movzbl (%eax),%eax
80109468:	0f b6 d8             	movzbl %al,%ebx
8010946b:	8b 45 08             	mov    0x8(%ebp),%eax
8010946e:	83 c0 02             	add    $0x2,%eax
80109471:	0f b6 00             	movzbl (%eax),%eax
80109474:	0f b6 c8             	movzbl %al,%ecx
80109477:	8b 45 08             	mov    0x8(%ebp),%eax
8010947a:	83 c0 01             	add    $0x1,%eax
8010947d:	0f b6 00             	movzbl (%eax),%eax
80109480:	0f b6 d0             	movzbl %al,%edx
80109483:	8b 45 08             	mov    0x8(%ebp),%eax
80109486:	0f b6 00             	movzbl (%eax),%eax
80109489:	0f b6 c0             	movzbl %al,%eax
8010948c:	83 ec 04             	sub    $0x4,%esp
8010948f:	57                   	push   %edi
80109490:	56                   	push   %esi
80109491:	53                   	push   %ebx
80109492:	51                   	push   %ecx
80109493:	52                   	push   %edx
80109494:	50                   	push   %eax
80109495:	68 e4 c0 10 80       	push   $0x8010c0e4
8010949a:	e8 55 6f ff ff       	call   801003f4 <cprintf>
8010949f:	83 c4 20             	add    $0x20,%esp
}
801094a2:	90                   	nop
801094a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801094a6:	5b                   	pop    %ebx
801094a7:	5e                   	pop    %esi
801094a8:	5f                   	pop    %edi
801094a9:	5d                   	pop    %ebp
801094aa:	c3                   	ret

801094ab <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801094ab:	55                   	push   %ebp
801094ac:	89 e5                	mov    %esp,%ebp
801094ae:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801094b1:	8b 45 08             	mov    0x8(%ebp),%eax
801094b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801094b7:	8b 45 08             	mov    0x8(%ebp),%eax
801094ba:	83 c0 0e             	add    $0xe,%eax
801094bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801094c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094c3:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094c7:	3c 08                	cmp    $0x8,%al
801094c9:	75 1b                	jne    801094e6 <eth_proc+0x3b>
801094cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094ce:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801094d2:	3c 06                	cmp    $0x6,%al
801094d4:	75 10                	jne    801094e6 <eth_proc+0x3b>
    arp_proc(pkt_addr);
801094d6:	83 ec 0c             	sub    $0xc,%esp
801094d9:	ff 75 f0             	push   -0x10(%ebp)
801094dc:	e8 01 f8 ff ff       	call   80108ce2 <arp_proc>
801094e1:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801094e4:	eb 24                	jmp    8010950a <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801094e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e9:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801094ed:	3c 08                	cmp    $0x8,%al
801094ef:	75 19                	jne    8010950a <eth_proc+0x5f>
801094f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094f4:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801094f8:	84 c0                	test   %al,%al
801094fa:	75 0e                	jne    8010950a <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
801094fc:	83 ec 0c             	sub    $0xc,%esp
801094ff:	ff 75 08             	push   0x8(%ebp)
80109502:	e8 8d 00 00 00       	call   80109594 <ipv4_proc>
80109507:	83 c4 10             	add    $0x10,%esp
}
8010950a:	90                   	nop
8010950b:	c9                   	leave
8010950c:	c3                   	ret

8010950d <N2H_ushort>:

ushort N2H_ushort(ushort value){
8010950d:	55                   	push   %ebp
8010950e:	89 e5                	mov    %esp,%ebp
80109510:	83 ec 04             	sub    $0x4,%esp
80109513:	8b 45 08             	mov    0x8(%ebp),%eax
80109516:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010951a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010951e:	66 c1 c0 08          	rol    $0x8,%ax
}
80109522:	c9                   	leave
80109523:	c3                   	ret

80109524 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109524:	55                   	push   %ebp
80109525:	89 e5                	mov    %esp,%ebp
80109527:	83 ec 04             	sub    $0x4,%esp
8010952a:	8b 45 08             	mov    0x8(%ebp),%eax
8010952d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109531:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109535:	66 c1 c0 08          	rol    $0x8,%ax
}
80109539:	c9                   	leave
8010953a:	c3                   	ret

8010953b <H2N_uint>:

uint H2N_uint(uint value){
8010953b:	55                   	push   %ebp
8010953c:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
8010953e:	8b 45 08             	mov    0x8(%ebp),%eax
80109541:	c1 e0 18             	shl    $0x18,%eax
80109544:	25 00 00 00 0f       	and    $0xf000000,%eax
80109549:	89 c2                	mov    %eax,%edx
8010954b:	8b 45 08             	mov    0x8(%ebp),%eax
8010954e:	c1 e0 08             	shl    $0x8,%eax
80109551:	25 00 f0 00 00       	and    $0xf000,%eax
80109556:	09 c2                	or     %eax,%edx
80109558:	8b 45 08             	mov    0x8(%ebp),%eax
8010955b:	c1 e8 08             	shr    $0x8,%eax
8010955e:	83 e0 0f             	and    $0xf,%eax
80109561:	01 d0                	add    %edx,%eax
}
80109563:	5d                   	pop    %ebp
80109564:	c3                   	ret

80109565 <N2H_uint>:

uint N2H_uint(uint value){
80109565:	55                   	push   %ebp
80109566:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
80109568:	8b 45 08             	mov    0x8(%ebp),%eax
8010956b:	c1 e0 18             	shl    $0x18,%eax
8010956e:	89 c2                	mov    %eax,%edx
80109570:	8b 45 08             	mov    0x8(%ebp),%eax
80109573:	c1 e0 08             	shl    $0x8,%eax
80109576:	25 00 00 ff 00       	and    $0xff0000,%eax
8010957b:	01 c2                	add    %eax,%edx
8010957d:	8b 45 08             	mov    0x8(%ebp),%eax
80109580:	c1 e8 08             	shr    $0x8,%eax
80109583:	25 00 ff 00 00       	and    $0xff00,%eax
80109588:	01 c2                	add    %eax,%edx
8010958a:	8b 45 08             	mov    0x8(%ebp),%eax
8010958d:	c1 e8 18             	shr    $0x18,%eax
80109590:	01 d0                	add    %edx,%eax
}
80109592:	5d                   	pop    %ebp
80109593:	c3                   	ret

80109594 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109594:	55                   	push   %ebp
80109595:	89 e5                	mov    %esp,%ebp
80109597:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010959a:	8b 45 08             	mov    0x8(%ebp),%eax
8010959d:	83 c0 0e             	add    $0xe,%eax
801095a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801095a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095a6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095aa:	0f b7 d0             	movzwl %ax,%edx
801095ad:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801095b2:	39 c2                	cmp    %eax,%edx
801095b4:	74 60                	je     80109616 <ipv4_proc+0x82>
801095b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b9:	83 c0 0c             	add    $0xc,%eax
801095bc:	83 ec 04             	sub    $0x4,%esp
801095bf:	6a 04                	push   $0x4
801095c1:	50                   	push   %eax
801095c2:	68 e4 f4 10 80       	push   $0x8010f4e4
801095c7:	e8 1c b5 ff ff       	call   80104ae8 <memcmp>
801095cc:	83 c4 10             	add    $0x10,%esp
801095cf:	85 c0                	test   %eax,%eax
801095d1:	74 43                	je     80109616 <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801095d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095d6:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801095da:	0f b7 c0             	movzwl %ax,%eax
801095dd:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801095e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095e5:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801095e9:	3c 01                	cmp    $0x1,%al
801095eb:	75 10                	jne    801095fd <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801095ed:	83 ec 0c             	sub    $0xc,%esp
801095f0:	ff 75 08             	push   0x8(%ebp)
801095f3:	e8 a3 00 00 00       	call   8010969b <icmp_proc>
801095f8:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801095fb:	eb 19                	jmp    80109616 <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
801095fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109600:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109604:	3c 06                	cmp    $0x6,%al
80109606:	75 0e                	jne    80109616 <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
80109608:	83 ec 0c             	sub    $0xc,%esp
8010960b:	ff 75 08             	push   0x8(%ebp)
8010960e:	e8 b3 03 00 00       	call   801099c6 <tcp_proc>
80109613:	83 c4 10             	add    $0x10,%esp
}
80109616:	90                   	nop
80109617:	c9                   	leave
80109618:	c3                   	ret

80109619 <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
80109619:	55                   	push   %ebp
8010961a:	89 e5                	mov    %esp,%ebp
8010961c:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
8010961f:	8b 45 08             	mov    0x8(%ebp),%eax
80109622:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109625:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109628:	0f b6 00             	movzbl (%eax),%eax
8010962b:	83 e0 0f             	and    $0xf,%eax
8010962e:	01 c0                	add    %eax,%eax
80109630:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109633:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010963a:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109641:	eb 48                	jmp    8010968b <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109643:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109646:	01 c0                	add    %eax,%eax
80109648:	89 c2                	mov    %eax,%edx
8010964a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010964d:	01 d0                	add    %edx,%eax
8010964f:	0f b6 00             	movzbl (%eax),%eax
80109652:	0f b6 c0             	movzbl %al,%eax
80109655:	c1 e0 08             	shl    $0x8,%eax
80109658:	89 c2                	mov    %eax,%edx
8010965a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010965d:	01 c0                	add    %eax,%eax
8010965f:	8d 48 01             	lea    0x1(%eax),%ecx
80109662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109665:	01 c8                	add    %ecx,%eax
80109667:	0f b6 00             	movzbl (%eax),%eax
8010966a:	0f b6 c0             	movzbl %al,%eax
8010966d:	01 d0                	add    %edx,%eax
8010966f:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109672:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
80109679:	76 0c                	jbe    80109687 <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010967b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010967e:	0f b7 c0             	movzwl %ax,%eax
80109681:	83 c0 01             	add    $0x1,%eax
80109684:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
80109687:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010968b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
8010968f:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109692:	7c af                	jl     80109643 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109694:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109697:	f7 d0                	not    %eax
}
80109699:	c9                   	leave
8010969a:	c3                   	ret

8010969b <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010969b:	55                   	push   %ebp
8010969c:	89 e5                	mov    %esp,%ebp
8010969e:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801096a1:	8b 45 08             	mov    0x8(%ebp),%eax
801096a4:	83 c0 0e             	add    $0xe,%eax
801096a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801096aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096ad:	0f b6 00             	movzbl (%eax),%eax
801096b0:	0f b6 c0             	movzbl %al,%eax
801096b3:	83 e0 0f             	and    $0xf,%eax
801096b6:	c1 e0 02             	shl    $0x2,%eax
801096b9:	89 c2                	mov    %eax,%edx
801096bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096be:	01 d0                	add    %edx,%eax
801096c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801096c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096c6:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801096ca:	84 c0                	test   %al,%al
801096cc:	75 4f                	jne    8010971d <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801096ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801096d1:	0f b6 00             	movzbl (%eax),%eax
801096d4:	3c 08                	cmp    $0x8,%al
801096d6:	75 45                	jne    8010971d <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801096d8:	e8 cb 90 ff ff       	call   801027a8 <kalloc>
801096dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801096e0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801096e7:	83 ec 04             	sub    $0x4,%esp
801096ea:	8d 45 e8             	lea    -0x18(%ebp),%eax
801096ed:	50                   	push   %eax
801096ee:	ff 75 ec             	push   -0x14(%ebp)
801096f1:	ff 75 08             	push   0x8(%ebp)
801096f4:	e8 78 00 00 00       	call   80109771 <icmp_reply_pkt_create>
801096f9:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
801096fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096ff:	83 ec 08             	sub    $0x8,%esp
80109702:	50                   	push   %eax
80109703:	ff 75 ec             	push   -0x14(%ebp)
80109706:	e8 ad f4 ff ff       	call   80108bb8 <i8254_send>
8010970b:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
8010970e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109711:	83 ec 0c             	sub    $0xc,%esp
80109714:	50                   	push   %eax
80109715:	e8 f4 8f ff ff       	call   8010270e <kfree>
8010971a:	83 c4 10             	add    $0x10,%esp
    }
  }
}
8010971d:	90                   	nop
8010971e:	c9                   	leave
8010971f:	c3                   	ret

80109720 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109720:	55                   	push   %ebp
80109721:	89 e5                	mov    %esp,%ebp
80109723:	53                   	push   %ebx
80109724:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
80109727:	8b 45 08             	mov    0x8(%ebp),%eax
8010972a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
8010972e:	0f b7 c0             	movzwl %ax,%eax
80109731:	83 ec 0c             	sub    $0xc,%esp
80109734:	50                   	push   %eax
80109735:	e8 d3 fd ff ff       	call   8010950d <N2H_ushort>
8010973a:	83 c4 10             	add    $0x10,%esp
8010973d:	0f b7 d8             	movzwl %ax,%ebx
80109740:	8b 45 08             	mov    0x8(%ebp),%eax
80109743:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80109747:	0f b7 c0             	movzwl %ax,%eax
8010974a:	83 ec 0c             	sub    $0xc,%esp
8010974d:	50                   	push   %eax
8010974e:	e8 ba fd ff ff       	call   8010950d <N2H_ushort>
80109753:	83 c4 10             	add    $0x10,%esp
80109756:	0f b7 c0             	movzwl %ax,%eax
80109759:	83 ec 04             	sub    $0x4,%esp
8010975c:	53                   	push   %ebx
8010975d:	50                   	push   %eax
8010975e:	68 03 c1 10 80       	push   $0x8010c103
80109763:	e8 8c 6c ff ff       	call   801003f4 <cprintf>
80109768:	83 c4 10             	add    $0x10,%esp
}
8010976b:	90                   	nop
8010976c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010976f:	c9                   	leave
80109770:	c3                   	ret

80109771 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109771:	55                   	push   %ebp
80109772:	89 e5                	mov    %esp,%ebp
80109774:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109777:	8b 45 08             	mov    0x8(%ebp),%eax
8010977a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
8010977d:	8b 45 08             	mov    0x8(%ebp),%eax
80109780:	83 c0 0e             	add    $0xe,%eax
80109783:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
80109786:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109789:	0f b6 00             	movzbl (%eax),%eax
8010978c:	0f b6 c0             	movzbl %al,%eax
8010978f:	83 e0 0f             	and    $0xf,%eax
80109792:	c1 e0 02             	shl    $0x2,%eax
80109795:	89 c2                	mov    %eax,%edx
80109797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010979a:	01 d0                	add    %edx,%eax
8010979c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
8010979f:	8b 45 0c             	mov    0xc(%ebp),%eax
801097a2:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801097a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801097a8:	83 c0 0e             	add    $0xe,%eax
801097ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801097ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097b1:	83 c0 14             	add    $0x14,%eax
801097b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801097b7:	8b 45 10             	mov    0x10(%ebp),%eax
801097ba:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801097c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801097c3:	8d 50 06             	lea    0x6(%eax),%edx
801097c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097c9:	83 ec 04             	sub    $0x4,%esp
801097cc:	6a 06                	push   $0x6
801097ce:	52                   	push   %edx
801097cf:	50                   	push   %eax
801097d0:	e8 6b b3 ff ff       	call   80104b40 <memmove>
801097d5:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801097d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097db:	83 c0 06             	add    $0x6,%eax
801097de:	83 ec 04             	sub    $0x4,%esp
801097e1:	6a 06                	push   $0x6
801097e3:	68 80 6c 19 80       	push   $0x80196c80
801097e8:	50                   	push   %eax
801097e9:	e8 52 b3 ff ff       	call   80104b40 <memmove>
801097ee:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801097f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097f4:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801097f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801097fb:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
801097ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109802:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109805:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109808:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
8010980c:	83 ec 0c             	sub    $0xc,%esp
8010980f:	6a 54                	push   $0x54
80109811:	e8 0e fd ff ff       	call   80109524 <H2N_ushort>
80109816:	83 c4 10             	add    $0x10,%esp
80109819:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010981c:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109820:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109827:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010982a:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
8010982e:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109835:	83 c0 01             	add    $0x1,%eax
80109838:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x4000);
8010983e:	83 ec 0c             	sub    $0xc,%esp
80109841:	68 00 40 00 00       	push   $0x4000
80109846:	e8 d9 fc ff ff       	call   80109524 <H2N_ushort>
8010984b:	83 c4 10             	add    $0x10,%esp
8010984e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109851:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109855:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109858:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
8010985c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010985f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109863:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109866:	83 c0 0c             	add    $0xc,%eax
80109869:	83 ec 04             	sub    $0x4,%esp
8010986c:	6a 04                	push   $0x4
8010986e:	68 e4 f4 10 80       	push   $0x8010f4e4
80109873:	50                   	push   %eax
80109874:	e8 c7 b2 ff ff       	call   80104b40 <memmove>
80109879:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
8010987c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010987f:	8d 50 0c             	lea    0xc(%eax),%edx
80109882:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109885:	83 c0 10             	add    $0x10,%eax
80109888:	83 ec 04             	sub    $0x4,%esp
8010988b:	6a 04                	push   $0x4
8010988d:	52                   	push   %edx
8010988e:	50                   	push   %eax
8010988f:	e8 ac b2 ff ff       	call   80104b40 <memmove>
80109894:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109897:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010989a:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
801098a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801098a3:	83 ec 0c             	sub    $0xc,%esp
801098a6:	50                   	push   %eax
801098a7:	e8 6d fd ff ff       	call   80109619 <ipv4_chksum>
801098ac:	83 c4 10             	add    $0x10,%esp
801098af:	0f b7 c0             	movzwl %ax,%eax
801098b2:	83 ec 0c             	sub    $0xc,%esp
801098b5:	50                   	push   %eax
801098b6:	e8 69 fc ff ff       	call   80109524 <H2N_ushort>
801098bb:	83 c4 10             	add    $0x10,%esp
801098be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801098c1:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
801098c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098c8:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
801098cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098ce:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
801098d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098d5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801098d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098dc:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
801098e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098e3:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801098e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098ea:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
801098ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801098f1:	8d 50 08             	lea    0x8(%eax),%edx
801098f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801098f7:	83 c0 08             	add    $0x8,%eax
801098fa:	83 ec 04             	sub    $0x4,%esp
801098fd:	6a 08                	push   $0x8
801098ff:	52                   	push   %edx
80109900:	50                   	push   %eax
80109901:	e8 3a b2 ff ff       	call   80104b40 <memmove>
80109906:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
80109909:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010990c:	8d 50 10             	lea    0x10(%eax),%edx
8010990f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109912:	83 c0 10             	add    $0x10,%eax
80109915:	83 ec 04             	sub    $0x4,%esp
80109918:	6a 30                	push   $0x30
8010991a:	52                   	push   %edx
8010991b:	50                   	push   %eax
8010991c:	e8 1f b2 ff ff       	call   80104b40 <memmove>
80109921:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109924:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109927:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
8010992d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109930:	83 ec 0c             	sub    $0xc,%esp
80109933:	50                   	push   %eax
80109934:	e8 1c 00 00 00       	call   80109955 <icmp_chksum>
80109939:	83 c4 10             	add    $0x10,%esp
8010993c:	0f b7 c0             	movzwl %ax,%eax
8010993f:	83 ec 0c             	sub    $0xc,%esp
80109942:	50                   	push   %eax
80109943:	e8 dc fb ff ff       	call   80109524 <H2N_ushort>
80109948:	83 c4 10             	add    $0x10,%esp
8010994b:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010994e:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109952:	90                   	nop
80109953:	c9                   	leave
80109954:	c3                   	ret

80109955 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109955:	55                   	push   %ebp
80109956:	89 e5                	mov    %esp,%ebp
80109958:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010995b:	8b 45 08             	mov    0x8(%ebp),%eax
8010995e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109961:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
80109968:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010996f:	eb 48                	jmp    801099b9 <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109971:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109974:	01 c0                	add    %eax,%eax
80109976:	89 c2                	mov    %eax,%edx
80109978:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010997b:	01 d0                	add    %edx,%eax
8010997d:	0f b6 00             	movzbl (%eax),%eax
80109980:	0f b6 c0             	movzbl %al,%eax
80109983:	c1 e0 08             	shl    $0x8,%eax
80109986:	89 c2                	mov    %eax,%edx
80109988:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010998b:	01 c0                	add    %eax,%eax
8010998d:	8d 48 01             	lea    0x1(%eax),%ecx
80109990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109993:	01 c8                	add    %ecx,%eax
80109995:	0f b6 00             	movzbl (%eax),%eax
80109998:	0f b6 c0             	movzbl %al,%eax
8010999b:	01 d0                	add    %edx,%eax
8010999d:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801099a0:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801099a7:	76 0c                	jbe    801099b5 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
801099a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099ac:	0f b7 c0             	movzwl %ax,%eax
801099af:	83 c0 01             	add    $0x1,%eax
801099b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801099b5:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801099b9:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801099bd:	7e b2                	jle    80109971 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801099bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
801099c2:	f7 d0                	not    %eax
}
801099c4:	c9                   	leave
801099c5:	c3                   	ret

801099c6 <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
801099c6:	55                   	push   %ebp
801099c7:	89 e5                	mov    %esp,%ebp
801099c9:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
801099cc:	8b 45 08             	mov    0x8(%ebp),%eax
801099cf:	83 c0 0e             	add    $0xe,%eax
801099d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801099d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099d8:	0f b6 00             	movzbl (%eax),%eax
801099db:	0f b6 c0             	movzbl %al,%eax
801099de:	83 e0 0f             	and    $0xf,%eax
801099e1:	c1 e0 02             	shl    $0x2,%eax
801099e4:	89 c2                	mov    %eax,%edx
801099e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801099e9:	01 d0                	add    %edx,%eax
801099eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
801099ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801099f1:	83 c0 14             	add    $0x14,%eax
801099f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
801099f7:	e8 ac 8d ff ff       	call   801027a8 <kalloc>
801099fc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
801099ff:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
80109a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a09:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a0d:	0f b6 c0             	movzbl %al,%eax
80109a10:	83 e0 02             	and    $0x2,%eax
80109a13:	85 c0                	test   %eax,%eax
80109a15:	74 3d                	je     80109a54 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
80109a17:	83 ec 0c             	sub    $0xc,%esp
80109a1a:	6a 00                	push   $0x0
80109a1c:	6a 12                	push   $0x12
80109a1e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a21:	50                   	push   %eax
80109a22:	ff 75 e8             	push   -0x18(%ebp)
80109a25:	ff 75 08             	push   0x8(%ebp)
80109a28:	e8 a2 01 00 00       	call   80109bcf <tcp_pkt_create>
80109a2d:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109a30:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a33:	83 ec 08             	sub    $0x8,%esp
80109a36:	50                   	push   %eax
80109a37:	ff 75 e8             	push   -0x18(%ebp)
80109a3a:	e8 79 f1 ff ff       	call   80108bb8 <i8254_send>
80109a3f:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a42:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109a47:	83 c0 01             	add    $0x1,%eax
80109a4a:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109a4f:	e9 69 01 00 00       	jmp    80109bbd <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a57:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a5b:	3c 18                	cmp    $0x18,%al
80109a5d:	0f 85 10 01 00 00    	jne    80109b73 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109a63:	83 ec 04             	sub    $0x4,%esp
80109a66:	6a 03                	push   $0x3
80109a68:	68 1e c1 10 80       	push   $0x8010c11e
80109a6d:	ff 75 ec             	push   -0x14(%ebp)
80109a70:	e8 73 b0 ff ff       	call   80104ae8 <memcmp>
80109a75:	83 c4 10             	add    $0x10,%esp
80109a78:	85 c0                	test   %eax,%eax
80109a7a:	74 74                	je     80109af0 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109a7c:	83 ec 0c             	sub    $0xc,%esp
80109a7f:	68 22 c1 10 80       	push   $0x8010c122
80109a84:	e8 6b 69 ff ff       	call   801003f4 <cprintf>
80109a89:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109a8c:	83 ec 0c             	sub    $0xc,%esp
80109a8f:	6a 00                	push   $0x0
80109a91:	6a 10                	push   $0x10
80109a93:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a96:	50                   	push   %eax
80109a97:	ff 75 e8             	push   -0x18(%ebp)
80109a9a:	ff 75 08             	push   0x8(%ebp)
80109a9d:	e8 2d 01 00 00       	call   80109bcf <tcp_pkt_create>
80109aa2:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109aa5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109aa8:	83 ec 08             	sub    $0x8,%esp
80109aab:	50                   	push   %eax
80109aac:	ff 75 e8             	push   -0x18(%ebp)
80109aaf:	e8 04 f1 ff ff       	call   80108bb8 <i8254_send>
80109ab4:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109ab7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109aba:	83 c0 36             	add    $0x36,%eax
80109abd:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109ac0:	8d 45 d8             	lea    -0x28(%ebp),%eax
80109ac3:	50                   	push   %eax
80109ac4:	ff 75 e0             	push   -0x20(%ebp)
80109ac7:	6a 00                	push   $0x0
80109ac9:	6a 00                	push   $0x0
80109acb:	e8 5a 04 00 00       	call   80109f2a <http_proc>
80109ad0:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109ad3:	8b 45 d8             	mov    -0x28(%ebp),%eax
80109ad6:	83 ec 0c             	sub    $0xc,%esp
80109ad9:	50                   	push   %eax
80109ada:	6a 18                	push   $0x18
80109adc:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109adf:	50                   	push   %eax
80109ae0:	ff 75 e8             	push   -0x18(%ebp)
80109ae3:	ff 75 08             	push   0x8(%ebp)
80109ae6:	e8 e4 00 00 00       	call   80109bcf <tcp_pkt_create>
80109aeb:	83 c4 20             	add    $0x20,%esp
80109aee:	eb 62                	jmp    80109b52 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109af0:	83 ec 0c             	sub    $0xc,%esp
80109af3:	6a 00                	push   $0x0
80109af5:	6a 10                	push   $0x10
80109af7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109afa:	50                   	push   %eax
80109afb:	ff 75 e8             	push   -0x18(%ebp)
80109afe:	ff 75 08             	push   0x8(%ebp)
80109b01:	e8 c9 00 00 00       	call   80109bcf <tcp_pkt_create>
80109b06:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109b09:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b0c:	83 ec 08             	sub    $0x8,%esp
80109b0f:	50                   	push   %eax
80109b10:	ff 75 e8             	push   -0x18(%ebp)
80109b13:	e8 a0 f0 ff ff       	call   80108bb8 <i8254_send>
80109b18:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109b1b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b1e:	83 c0 36             	add    $0x36,%eax
80109b21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109b24:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109b27:	50                   	push   %eax
80109b28:	ff 75 e4             	push   -0x1c(%ebp)
80109b2b:	6a 00                	push   $0x0
80109b2d:	6a 00                	push   $0x0
80109b2f:	e8 f6 03 00 00       	call   80109f2a <http_proc>
80109b34:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109b37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109b3a:	83 ec 0c             	sub    $0xc,%esp
80109b3d:	50                   	push   %eax
80109b3e:	6a 18                	push   $0x18
80109b40:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b43:	50                   	push   %eax
80109b44:	ff 75 e8             	push   -0x18(%ebp)
80109b47:	ff 75 08             	push   0x8(%ebp)
80109b4a:	e8 80 00 00 00       	call   80109bcf <tcp_pkt_create>
80109b4f:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109b52:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109b55:	83 ec 08             	sub    $0x8,%esp
80109b58:	50                   	push   %eax
80109b59:	ff 75 e8             	push   -0x18(%ebp)
80109b5c:	e8 57 f0 ff ff       	call   80108bb8 <i8254_send>
80109b61:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109b64:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109b69:	83 c0 01             	add    $0x1,%eax
80109b6c:	a3 64 6f 19 80       	mov    %eax,0x80196f64
80109b71:	eb 4a                	jmp    80109bbd <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109b73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109b76:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109b7a:	3c 10                	cmp    $0x10,%al
80109b7c:	75 3f                	jne    80109bbd <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109b7e:	a1 68 6f 19 80       	mov    0x80196f68,%eax
80109b83:	83 f8 01             	cmp    $0x1,%eax
80109b86:	75 35                	jne    80109bbd <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109b88:	83 ec 0c             	sub    $0xc,%esp
80109b8b:	6a 00                	push   $0x0
80109b8d:	6a 01                	push   $0x1
80109b8f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109b92:	50                   	push   %eax
80109b93:	ff 75 e8             	push   -0x18(%ebp)
80109b96:	ff 75 08             	push   0x8(%ebp)
80109b99:	e8 31 00 00 00       	call   80109bcf <tcp_pkt_create>
80109b9e:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109ba1:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109ba4:	83 ec 08             	sub    $0x8,%esp
80109ba7:	50                   	push   %eax
80109ba8:	ff 75 e8             	push   -0x18(%ebp)
80109bab:	e8 08 f0 ff ff       	call   80108bb8 <i8254_send>
80109bb0:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109bb3:	c7 05 68 6f 19 80 00 	movl   $0x0,0x80196f68
80109bba:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109bbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109bc0:	83 ec 0c             	sub    $0xc,%esp
80109bc3:	50                   	push   %eax
80109bc4:	e8 45 8b ff ff       	call   8010270e <kfree>
80109bc9:	83 c4 10             	add    $0x10,%esp
}
80109bcc:	90                   	nop
80109bcd:	c9                   	leave
80109bce:	c3                   	ret

80109bcf <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109bcf:	55                   	push   %ebp
80109bd0:	89 e5                	mov    %esp,%ebp
80109bd2:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80109bd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109bdb:	8b 45 08             	mov    0x8(%ebp),%eax
80109bde:	83 c0 0e             	add    $0xe,%eax
80109be1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109be4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be7:	0f b6 00             	movzbl (%eax),%eax
80109bea:	0f b6 c0             	movzbl %al,%eax
80109bed:	83 e0 0f             	and    $0xf,%eax
80109bf0:	c1 e0 02             	shl    $0x2,%eax
80109bf3:	89 c2                	mov    %eax,%edx
80109bf5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109bf8:	01 d0                	add    %edx,%eax
80109bfa:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109bfd:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c00:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109c03:	8b 45 0c             	mov    0xc(%ebp),%eax
80109c06:	83 c0 0e             	add    $0xe,%eax
80109c09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c0f:	83 c0 14             	add    $0x14,%eax
80109c12:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109c15:	8b 45 18             	mov    0x18(%ebp),%eax
80109c18:	8d 50 36             	lea    0x36(%eax),%edx
80109c1b:	8b 45 10             	mov    0x10(%ebp),%eax
80109c1e:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109c23:	8d 50 06             	lea    0x6(%eax),%edx
80109c26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c29:	83 ec 04             	sub    $0x4,%esp
80109c2c:	6a 06                	push   $0x6
80109c2e:	52                   	push   %edx
80109c2f:	50                   	push   %eax
80109c30:	e8 0b af ff ff       	call   80104b40 <memmove>
80109c35:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109c38:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c3b:	83 c0 06             	add    $0x6,%eax
80109c3e:	83 ec 04             	sub    $0x4,%esp
80109c41:	6a 06                	push   $0x6
80109c43:	68 80 6c 19 80       	push   $0x80196c80
80109c48:	50                   	push   %eax
80109c49:	e8 f2 ae ff ff       	call   80104b40 <memmove>
80109c4e:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109c51:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c54:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109c58:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109c5b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109c5f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c62:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109c65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c68:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109c6c:	8b 45 18             	mov    0x18(%ebp),%eax
80109c6f:	83 c0 28             	add    $0x28,%eax
80109c72:	0f b7 c0             	movzwl %ax,%eax
80109c75:	83 ec 0c             	sub    $0xc,%esp
80109c78:	50                   	push   %eax
80109c79:	e8 a6 f8 ff ff       	call   80109524 <H2N_ushort>
80109c7e:	83 c4 10             	add    $0x10,%esp
80109c81:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c84:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109c88:	0f b7 15 60 6f 19 80 	movzwl 0x80196f60,%edx
80109c8f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c92:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109c96:	0f b7 05 60 6f 19 80 	movzwl 0x80196f60,%eax
80109c9d:	83 c0 01             	add    $0x1,%eax
80109ca0:	66 a3 60 6f 19 80    	mov    %ax,0x80196f60
  ipv4_send->fragment = H2N_ushort(0x0000);
80109ca6:	83 ec 0c             	sub    $0xc,%esp
80109ca9:	6a 00                	push   $0x0
80109cab:	e8 74 f8 ff ff       	call   80109524 <H2N_ushort>
80109cb0:	83 c4 10             	add    $0x10,%esp
80109cb3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109cb6:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109cba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cbd:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109cc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cc4:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109cc8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ccb:	83 c0 0c             	add    $0xc,%eax
80109cce:	83 ec 04             	sub    $0x4,%esp
80109cd1:	6a 04                	push   $0x4
80109cd3:	68 e4 f4 10 80       	push   $0x8010f4e4
80109cd8:	50                   	push   %eax
80109cd9:	e8 62 ae ff ff       	call   80104b40 <memmove>
80109cde:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109ce4:	8d 50 0c             	lea    0xc(%eax),%edx
80109ce7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cea:	83 c0 10             	add    $0x10,%eax
80109ced:	83 ec 04             	sub    $0x4,%esp
80109cf0:	6a 04                	push   $0x4
80109cf2:	52                   	push   %edx
80109cf3:	50                   	push   %eax
80109cf4:	e8 47 ae ff ff       	call   80104b40 <memmove>
80109cf9:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109cfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cff:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109d05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109d08:	83 ec 0c             	sub    $0xc,%esp
80109d0b:	50                   	push   %eax
80109d0c:	e8 08 f9 ff ff       	call   80109619 <ipv4_chksum>
80109d11:	83 c4 10             	add    $0x10,%esp
80109d14:	0f b7 c0             	movzwl %ax,%eax
80109d17:	83 ec 0c             	sub    $0xc,%esp
80109d1a:	50                   	push   %eax
80109d1b:	e8 04 f8 ff ff       	call   80109524 <H2N_ushort>
80109d20:	83 c4 10             	add    $0x10,%esp
80109d23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109d26:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109d2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d2d:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d34:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109d37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d3a:	0f b7 10             	movzwl (%eax),%edx
80109d3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d40:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109d44:	a1 64 6f 19 80       	mov    0x80196f64,%eax
80109d49:	83 ec 0c             	sub    $0xc,%esp
80109d4c:	50                   	push   %eax
80109d4d:	e8 e9 f7 ff ff       	call   8010953b <H2N_uint>
80109d52:	83 c4 10             	add    $0x10,%esp
80109d55:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109d58:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109d5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109d5e:	8b 40 04             	mov    0x4(%eax),%eax
80109d61:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109d67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d6a:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109d6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d70:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109d74:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d77:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109d7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d7e:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109d82:	8b 45 14             	mov    0x14(%ebp),%eax
80109d85:	89 c2                	mov    %eax,%edx
80109d87:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d8a:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109d8d:	83 ec 0c             	sub    $0xc,%esp
80109d90:	68 90 38 00 00       	push   $0x3890
80109d95:	e8 8a f7 ff ff       	call   80109524 <H2N_ushort>
80109d9a:	83 c4 10             	add    $0x10,%esp
80109d9d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109da0:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109da4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109da7:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109dad:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109db0:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109db6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db9:	83 ec 0c             	sub    $0xc,%esp
80109dbc:	50                   	push   %eax
80109dbd:	e8 1f 00 00 00       	call   80109de1 <tcp_chksum>
80109dc2:	83 c4 10             	add    $0x10,%esp
80109dc5:	83 c0 08             	add    $0x8,%eax
80109dc8:	0f b7 c0             	movzwl %ax,%eax
80109dcb:	83 ec 0c             	sub    $0xc,%esp
80109dce:	50                   	push   %eax
80109dcf:	e8 50 f7 ff ff       	call   80109524 <H2N_ushort>
80109dd4:	83 c4 10             	add    $0x10,%esp
80109dd7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109dda:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109dde:	90                   	nop
80109ddf:	c9                   	leave
80109de0:	c3                   	ret

80109de1 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109de1:	55                   	push   %ebp
80109de2:	89 e5                	mov    %esp,%ebp
80109de4:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109de7:	8b 45 08             	mov    0x8(%ebp),%eax
80109dea:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109ded:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109df0:	83 c0 14             	add    $0x14,%eax
80109df3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109df6:	83 ec 04             	sub    $0x4,%esp
80109df9:	6a 04                	push   $0x4
80109dfb:	68 e4 f4 10 80       	push   $0x8010f4e4
80109e00:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e03:	50                   	push   %eax
80109e04:	e8 37 ad ff ff       	call   80104b40 <memmove>
80109e09:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109e0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e0f:	83 c0 0c             	add    $0xc,%eax
80109e12:	83 ec 04             	sub    $0x4,%esp
80109e15:	6a 04                	push   $0x4
80109e17:	50                   	push   %eax
80109e18:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e1b:	83 c0 04             	add    $0x4,%eax
80109e1e:	50                   	push   %eax
80109e1f:	e8 1c ad ff ff       	call   80104b40 <memmove>
80109e24:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109e27:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109e2b:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109e2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109e32:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109e36:	0f b7 c0             	movzwl %ax,%eax
80109e39:	83 ec 0c             	sub    $0xc,%esp
80109e3c:	50                   	push   %eax
80109e3d:	e8 cb f6 ff ff       	call   8010950d <N2H_ushort>
80109e42:	83 c4 10             	add    $0x10,%esp
80109e45:	83 e8 14             	sub    $0x14,%eax
80109e48:	0f b7 c0             	movzwl %ax,%eax
80109e4b:	83 ec 0c             	sub    $0xc,%esp
80109e4e:	50                   	push   %eax
80109e4f:	e8 d0 f6 ff ff       	call   80109524 <H2N_ushort>
80109e54:	83 c4 10             	add    $0x10,%esp
80109e57:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109e5b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109e62:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109e65:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109e68:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109e6f:	eb 33                	jmp    80109ea4 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109e71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e74:	01 c0                	add    %eax,%eax
80109e76:	89 c2                	mov    %eax,%edx
80109e78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e7b:	01 d0                	add    %edx,%eax
80109e7d:	0f b6 00             	movzbl (%eax),%eax
80109e80:	0f b6 c0             	movzbl %al,%eax
80109e83:	c1 e0 08             	shl    $0x8,%eax
80109e86:	89 c2                	mov    %eax,%edx
80109e88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e8b:	01 c0                	add    %eax,%eax
80109e8d:	8d 48 01             	lea    0x1(%eax),%ecx
80109e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109e93:	01 c8                	add    %ecx,%eax
80109e95:	0f b6 00             	movzbl (%eax),%eax
80109e98:	0f b6 c0             	movzbl %al,%eax
80109e9b:	01 d0                	add    %edx,%eax
80109e9d:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109ea0:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109ea4:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109ea8:	7e c7                	jle    80109e71 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109eaa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109ead:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109eb0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109eb7:	eb 33                	jmp    80109eec <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109eb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ebc:	01 c0                	add    %eax,%eax
80109ebe:	89 c2                	mov    %eax,%edx
80109ec0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ec3:	01 d0                	add    %edx,%eax
80109ec5:	0f b6 00             	movzbl (%eax),%eax
80109ec8:	0f b6 c0             	movzbl %al,%eax
80109ecb:	c1 e0 08             	shl    $0x8,%eax
80109ece:	89 c2                	mov    %eax,%edx
80109ed0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109ed3:	01 c0                	add    %eax,%eax
80109ed5:	8d 48 01             	lea    0x1(%eax),%ecx
80109ed8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109edb:	01 c8                	add    %ecx,%eax
80109edd:	0f b6 00             	movzbl (%eax),%eax
80109ee0:	0f b6 c0             	movzbl %al,%eax
80109ee3:	01 d0                	add    %edx,%eax
80109ee5:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109ee8:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109eec:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109ef0:	0f b7 c0             	movzwl %ax,%eax
80109ef3:	83 ec 0c             	sub    $0xc,%esp
80109ef6:	50                   	push   %eax
80109ef7:	e8 11 f6 ff ff       	call   8010950d <N2H_ushort>
80109efc:	83 c4 10             	add    $0x10,%esp
80109eff:	66 d1 e8             	shr    $1,%ax
80109f02:	0f b7 c0             	movzwl %ax,%eax
80109f05:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109f08:	7c af                	jl     80109eb9 <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f0d:	c1 e8 10             	shr    $0x10,%eax
80109f10:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f16:	f7 d0                	not    %eax
}
80109f18:	c9                   	leave
80109f19:	c3                   	ret

80109f1a <tcp_fin>:

void tcp_fin(){
80109f1a:	55                   	push   %ebp
80109f1b:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109f1d:	c7 05 68 6f 19 80 01 	movl   $0x1,0x80196f68
80109f24:	00 00 00 
}
80109f27:	90                   	nop
80109f28:	5d                   	pop    %ebp
80109f29:	c3                   	ret

80109f2a <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109f2a:	55                   	push   %ebp
80109f2b:	89 e5                	mov    %esp,%ebp
80109f2d:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109f30:	8b 45 10             	mov    0x10(%ebp),%eax
80109f33:	83 ec 04             	sub    $0x4,%esp
80109f36:	6a 00                	push   $0x0
80109f38:	68 2b c1 10 80       	push   $0x8010c12b
80109f3d:	50                   	push   %eax
80109f3e:	e8 65 00 00 00       	call   80109fa8 <http_strcpy>
80109f43:	83 c4 10             	add    $0x10,%esp
80109f46:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109f49:	8b 45 10             	mov    0x10(%ebp),%eax
80109f4c:	83 ec 04             	sub    $0x4,%esp
80109f4f:	ff 75 f4             	push   -0xc(%ebp)
80109f52:	68 3e c1 10 80       	push   $0x8010c13e
80109f57:	50                   	push   %eax
80109f58:	e8 4b 00 00 00       	call   80109fa8 <http_strcpy>
80109f5d:	83 c4 10             	add    $0x10,%esp
80109f60:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109f63:	8b 45 10             	mov    0x10(%ebp),%eax
80109f66:	83 ec 04             	sub    $0x4,%esp
80109f69:	ff 75 f4             	push   -0xc(%ebp)
80109f6c:	68 59 c1 10 80       	push   $0x8010c159
80109f71:	50                   	push   %eax
80109f72:	e8 31 00 00 00       	call   80109fa8 <http_strcpy>
80109f77:	83 c4 10             	add    $0x10,%esp
80109f7a:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109f80:	83 e0 01             	and    $0x1,%eax
80109f83:	85 c0                	test   %eax,%eax
80109f85:	74 11                	je     80109f98 <http_proc+0x6e>
    char *payload = (char *)send;
80109f87:	8b 45 10             	mov    0x10(%ebp),%eax
80109f8a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109f8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109f93:	01 d0                	add    %edx,%eax
80109f95:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109f98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109f9b:	8b 45 14             	mov    0x14(%ebp),%eax
80109f9e:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109fa0:	e8 75 ff ff ff       	call   80109f1a <tcp_fin>
}
80109fa5:	90                   	nop
80109fa6:	c9                   	leave
80109fa7:	c3                   	ret

80109fa8 <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109fa8:	55                   	push   %ebp
80109fa9:	89 e5                	mov    %esp,%ebp
80109fab:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109fae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109fb5:	eb 20                	jmp    80109fd7 <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109fb7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fba:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fbd:	01 d0                	add    %edx,%eax
80109fbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109fc2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fc5:	01 ca                	add    %ecx,%edx
80109fc7:	89 d1                	mov    %edx,%ecx
80109fc9:	8b 55 08             	mov    0x8(%ebp),%edx
80109fcc:	01 ca                	add    %ecx,%edx
80109fce:	0f b6 00             	movzbl (%eax),%eax
80109fd1:	88 02                	mov    %al,(%edx)
    i++;
80109fd3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109fd7:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109fda:	8b 45 0c             	mov    0xc(%ebp),%eax
80109fdd:	01 d0                	add    %edx,%eax
80109fdf:	0f b6 00             	movzbl (%eax),%eax
80109fe2:	84 c0                	test   %al,%al
80109fe4:	75 d1                	jne    80109fb7 <http_strcpy+0xf>
  }
  return i;
80109fe6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109fe9:	c9                   	leave
80109fea:	c3                   	ret

80109feb <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109feb:	55                   	push   %ebp
80109fec:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109fee:	c7 05 70 6f 19 80 a2 	movl   $0x8010f5a2,0x80196f70
80109ff5:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109ff8:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109ffd:	c1 e8 09             	shr    $0x9,%eax
8010a000:	a3 6c 6f 19 80       	mov    %eax,0x80196f6c
}
8010a005:	90                   	nop
8010a006:	5d                   	pop    %ebp
8010a007:	c3                   	ret

8010a008 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010a008:	55                   	push   %ebp
8010a009:	89 e5                	mov    %esp,%ebp
  // no-op
}
8010a00b:	90                   	nop
8010a00c:	5d                   	pop    %ebp
8010a00d:	c3                   	ret

8010a00e <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010a00e:	55                   	push   %ebp
8010a00f:	89 e5                	mov    %esp,%ebp
8010a011:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
8010a014:	8b 45 08             	mov    0x8(%ebp),%eax
8010a017:	83 c0 0c             	add    $0xc,%eax
8010a01a:	83 ec 0c             	sub    $0xc,%esp
8010a01d:	50                   	push   %eax
8010a01e:	e8 57 a7 ff ff       	call   8010477a <holdingsleep>
8010a023:	83 c4 10             	add    $0x10,%esp
8010a026:	85 c0                	test   %eax,%eax
8010a028:	75 0d                	jne    8010a037 <iderw+0x29>
    panic("iderw: buf not locked");
8010a02a:	83 ec 0c             	sub    $0xc,%esp
8010a02d:	68 6a c1 10 80       	push   $0x8010c16a
8010a032:	e8 8a 65 ff ff       	call   801005c1 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010a037:	8b 45 08             	mov    0x8(%ebp),%eax
8010a03a:	8b 00                	mov    (%eax),%eax
8010a03c:	83 e0 06             	and    $0x6,%eax
8010a03f:	83 f8 02             	cmp    $0x2,%eax
8010a042:	75 0d                	jne    8010a051 <iderw+0x43>
    panic("iderw: nothing to do");
8010a044:	83 ec 0c             	sub    $0xc,%esp
8010a047:	68 80 c1 10 80       	push   $0x8010c180
8010a04c:	e8 70 65 ff ff       	call   801005c1 <panic>
  if(b->dev != 1)
8010a051:	8b 45 08             	mov    0x8(%ebp),%eax
8010a054:	8b 40 04             	mov    0x4(%eax),%eax
8010a057:	83 f8 01             	cmp    $0x1,%eax
8010a05a:	74 0d                	je     8010a069 <iderw+0x5b>
    panic("iderw: request not for disk 1");
8010a05c:	83 ec 0c             	sub    $0xc,%esp
8010a05f:	68 95 c1 10 80       	push   $0x8010c195
8010a064:	e8 58 65 ff ff       	call   801005c1 <panic>
  if(b->blockno >= disksize)
8010a069:	8b 45 08             	mov    0x8(%ebp),%eax
8010a06c:	8b 40 08             	mov    0x8(%eax),%eax
8010a06f:	8b 15 6c 6f 19 80    	mov    0x80196f6c,%edx
8010a075:	39 d0                	cmp    %edx,%eax
8010a077:	72 0d                	jb     8010a086 <iderw+0x78>
    panic("iderw: block out of range");
8010a079:	83 ec 0c             	sub    $0xc,%esp
8010a07c:	68 b3 c1 10 80       	push   $0x8010c1b3
8010a081:	e8 3b 65 ff ff       	call   801005c1 <panic>

  p = memdisk + b->blockno*BSIZE;
8010a086:	8b 15 70 6f 19 80    	mov    0x80196f70,%edx
8010a08c:	8b 45 08             	mov    0x8(%ebp),%eax
8010a08f:	8b 40 08             	mov    0x8(%eax),%eax
8010a092:	c1 e0 09             	shl    $0x9,%eax
8010a095:	01 d0                	add    %edx,%eax
8010a097:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
8010a09a:	8b 45 08             	mov    0x8(%ebp),%eax
8010a09d:	8b 00                	mov    (%eax),%eax
8010a09f:	83 e0 04             	and    $0x4,%eax
8010a0a2:	85 c0                	test   %eax,%eax
8010a0a4:	74 2b                	je     8010a0d1 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
8010a0a6:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0a9:	8b 00                	mov    (%eax),%eax
8010a0ab:	83 e0 fb             	and    $0xfffffffb,%eax
8010a0ae:	89 c2                	mov    %eax,%edx
8010a0b0:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0b3:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
8010a0b5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0b8:	83 c0 5c             	add    $0x5c,%eax
8010a0bb:	83 ec 04             	sub    $0x4,%esp
8010a0be:	68 00 02 00 00       	push   $0x200
8010a0c3:	50                   	push   %eax
8010a0c4:	ff 75 f4             	push   -0xc(%ebp)
8010a0c7:	e8 74 aa ff ff       	call   80104b40 <memmove>
8010a0cc:	83 c4 10             	add    $0x10,%esp
8010a0cf:	eb 1a                	jmp    8010a0eb <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
8010a0d1:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0d4:	83 c0 5c             	add    $0x5c,%eax
8010a0d7:	83 ec 04             	sub    $0x4,%esp
8010a0da:	68 00 02 00 00       	push   $0x200
8010a0df:	ff 75 f4             	push   -0xc(%ebp)
8010a0e2:	50                   	push   %eax
8010a0e3:	e8 58 aa ff ff       	call   80104b40 <memmove>
8010a0e8:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
8010a0eb:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0ee:	8b 00                	mov    (%eax),%eax
8010a0f0:	83 c8 02             	or     $0x2,%eax
8010a0f3:	89 c2                	mov    %eax,%edx
8010a0f5:	8b 45 08             	mov    0x8(%ebp),%eax
8010a0f8:	89 10                	mov    %edx,(%eax)
}
8010a0fa:	90                   	nop
8010a0fb:	c9                   	leave
8010a0fc:	c3                   	ret
