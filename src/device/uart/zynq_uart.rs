#![allow(dead_code)]
use tock_registers::interfaces::{Readable, Writeable};
use tock_registers::register_structs;
use tock_registers::registers::{ReadOnly, ReadWrite, WriteOnly};

use crate::memory::addr::{PhysAddr, VirtAddr};
use spin::Mutex;

pub const UART0_BASE: PhysAddr = 0xff000000;
pub const UART1_BASE: PhysAddr = 0xff010000;

lazy_static! {
    static ref UART0: Mutex<ZynqUart> = {
        let mut uart = ZynqUart::new(UART0_BASE);
        uart.init();
        Mutex::new(uart)
    };
}

lazy_static! {
    static ref UART1: Mutex<ZynqUart> = {
        let mut uart = ZynqUart::new(UART1_BASE);
        uart.init();
        Mutex::new(uart)
    };
}

register_structs! {
    ZynqUartRegs {
        (0x00 => d: ReadWrite<u32>),
        (0x04 => @END),
    }
}

struct ZynqUart {
    base_vaddr: VirtAddr,
}

impl ZynqUart {
    const fn new(base_vaddr: VirtAddr) -> Self {
        Self { base_vaddr }
    }

    const fn regs(&self) -> &ZynqUartRegs {
        unsafe { &*(self.base_vaddr as *const _) }
    }

    fn init(&mut self) {
        todo!();
    }

    fn putchar(&mut self, c: u8) {
        todo!();
    }

    fn getchar(&mut self) -> Option<u8> {
        todo!();
    }
}

pub fn console_putchar(c: u8) {
    UART0.lock().putchar(c)
}

pub fn console_getchar() -> Option<u8> {
    UART0.lock().getchar()
}
