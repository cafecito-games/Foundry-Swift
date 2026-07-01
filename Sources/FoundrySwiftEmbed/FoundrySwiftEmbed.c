// FoundrySwiftEmbed is a no-op FoundryExtension whose only purpose is to be a
// registered FoundryExtension in the FoundrySwift Foundry addon. The accompanying
// FoundrySwiftEmbed.foundryextension lists FoundrySwift under `[dependencies]`, which
// is what tells Foundry's iOS / macOS exporters to embed FoundrySwift.framework
// into the exported app exactly once.
//
// The shim deliberately:
//   - Registers no Foundry classes.
//   - Does not link against FoundrySwift. (If it did, SwiftPM would
//     statically link the entire FoundrySwift module into this binary,
//     producing a ~33 MB duplicate of FoundrySwift per platform slice.)
//   - Performs no work in its initialize / deinitialize callbacks.
//     FoundrySwift's runtime is initialized independently by whichever
//     consumer FoundryExtension(s) actually use it.
//
// The entry point still has to fully populate the FoundryExtensionInitialization
// struct Foundry hands in: returning 1 without setting the initialize and
// deinitialize callbacks leaves them null, which causes Foundry to log
//
//   initialize_library: Parameter "initialization.initialize" is null.
//
// once per init-level transition (CORE -> SCENE -> EDITOR) on every client
// start. The struct layout is duplicated inline so this stays a standalone C
// target with no dependency on the FoundryExtensionC headers target.

#include <stddef.h>
#include <stdint.h>

typedef enum {
    FOUNDRY_EXTENSION_INITIALIZATION_CORE = 0,
    FOUNDRY_EXTENSION_INITIALIZATION_SERVERS = 1,
    FOUNDRY_EXTENSION_INITIALIZATION_SCENE = 2,
    FOUNDRY_EXTENSION_INITIALIZATION_EDITOR = 3,
} FoundryExtensionInitializationLevel;

typedef void (*FoundryExtensionInitializeCallback)(void *p_userdata, FoundryExtensionInitializationLevel p_level);
typedef void (*FoundryExtensionDeinitializeCallback)(void *p_userdata, FoundryExtensionInitializationLevel p_level);

typedef struct {
    FoundryExtensionInitializationLevel minimum_initialization_level;
    void *userdata;
    FoundryExtensionInitializeCallback initialize;
    FoundryExtensionDeinitializeCallback deinitialize;
} FoundryExtensionInitialization;

static void foundry_swift_embed_initialize(void *userdata, FoundryExtensionInitializationLevel level) {
    (void)userdata;
    (void)level;
}

static void foundry_swift_embed_deinitialize(void *userdata, FoundryExtensionInitializationLevel level) {
    (void)userdata;
    (void)level;
}

uint8_t foundry_swift_embed_entry_point(void *foundry_get_proc_address,
                                        void *library,
                                        void *initialization) {
    (void)foundry_get_proc_address;
    (void)library;

    if (initialization == NULL) {
        return 0;
    }

    FoundryExtensionInitialization *init = (FoundryExtensionInitialization *)initialization;
    init->minimum_initialization_level = FOUNDRY_EXTENSION_INITIALIZATION_SCENE;
    init->userdata = NULL;
    init->initialize = foundry_swift_embed_initialize;
    init->deinitialize = foundry_swift_embed_deinitialize;
    return 1;
}
