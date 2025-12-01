#include "efi.h"


/**
 * efi_main
 * * This is the entry point for the UEFI application.
 * Unlike standard C, we don't use main(int argc, char **argv).
 * * @param ImageHandle The handle to the loaded image of this application.
 * @param SystemTable Pointer to the System Table (access to Console, BootServices, etc.)
 */
EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE* SystemTable) {
    // Set text to red fg and green bg
    SystemTable->ConOut->SetAttribute(SystemTable->ConOut, EFI_TEXT_ATTR(EFI_RED, EFI_GREEN));
    // Clear screen to bg color
    SystemTable->ConOut->ClearScreen(SystemTable->ConOut);
    SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Hello, word!\r\n\r\n");
    // Set text to red/black
    SystemTable->ConOut->SetAttribute(SystemTable->ConOut, EFI_TEXT_ATTR(EFI_RED, EFI_BLACK));
    SystemTable->ConOut->OutputString(SystemTable->ConOut, u"Press any key...");

    // NOTE: Setup debugging of UEFI application with debug hook
    volatile int WaitForDebug = 1;
    while (WaitForDebug) { }
    // Wait for keypress
    EFI_INPUT_KEY key;
    while(1) {
        while (SystemTable->ConIn->ReadKeyStroke(SystemTable->ConIn, &key) != EFI_SUCCESS);
        // TODO: fix this not working
        if (key.UnicodeChar == u'\n' + 3) {
            break;
        }
        SystemTable->ConOut->OutputString(SystemTable->ConOut, &key.UnicodeChar);
    }

    // Does not return
    SystemTable->RuntimeServices->ResetSystem(EfiResetShutdown, EFI_SUCCESS, 0, NULL);
    // Should never get here
    return EFI_SUCCESS;
}
