![header](header.png?raw=true)

A complete decompilation of Retro Engine v5 and v5Ultimate.

# **SUPPORT THE DEVELOPERS OF THE RETRO ENGINE**
We do not own the Retro Engine in any way, shape or form, and this project would not have been possible had they not developed RSDKv5(U) in the first place. Retro Engine is currently owned by [Evening Star](https://eveningstar.studio/); we highly urge you to follow & support their projects if you enjoyed this project of ours!

## **DO NOT USE THIS DECOMPILATION PROJECT AS A MEANS TO PIRATE SONIC MANIA (PLUS) OR ANY OTHER RSDKv5(U) GAMES.**
We do not condone using this project as a means for piracy in any form. This project was made with love and care for the source material and was created for purely educational purposes.

# Additional Tweaks
* Added a built-in mod loader and API allowing to easily create and play mods with features such as save file redirection and XML asset loading, supported by all sub-versions of v5U.
* Added a built-in shader compiler for backends/platforms that support it.
* Added various other backends to windows aside from the usual DirectX 9 backends


# IF YOU'RE HERE FOR SONIC MANIA

You have the option of building Sonic Mania and this fork in this repo: https://github.com/ant9012/Sonic-Mania-Decompilation-wasm/


# How to Build

This project uses [CMake](https://cmake.org/), a versatile building system that supports many different compilers and platforms. You can download CMake [here](https://cmake.org/download/). **(Make sure to enable the feature to add CMake to the system PATH during the installation if you're on Windows!)**

## Get the source code

**DO NOT** download the source code ZIP archive from GitHub, as they do not include the submodules required to build the decompilation.

Instead, you will need to clone the repository using Git, which you can get [here](https://git-scm.com/downloads).

Clone the repo **recursively**, using:
`git clone --recursive --single-branch --branch web https://github.com/ant9012/RSDKv5-Decompilation-wasm.git`

If you've already cloned the repo, run this command inside of the repository:
```git submodule update --init```

## Getting dependencies

The only dependency that you need is libtheora, which you can find at: https://xiph.org/downloads/. Any other dependency will be handled by Emscripten.

After installing those, run the following in Command Prompt (make sure to replace `[vcpkg root]` with the path to the vcpkg installation!):
- `[vcpkg root]/vcpkg.exe install libtheora libogg glew glfw3 sdl2 --triplet=x64-windows-static` (If you're compiling a 32-bit build, replace `x64-windows-static` with `x86-windows-static`.)

Finally, follow the [compilation steps below](#compiling) using `-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static` as arguments for `cmake -B build`.
  - Make sure to replace `[vcpkg root]` with the path to the vcpkg installation!
  - If you're compiling a 32-bit build, replace `x64-windows-static` with `x86-windows-static`.

### Linux
Install the following dependencies: then follow the [compilation steps below](#compiling):
- **pacman (Arch):** `sudo pacman -S base-devel cmake glew glfw libtheora`
- **apt (Debian/Ubuntu):** `sudo apt install build-essential cmake libglew-dev libglfw3-dev libtheora-dev`
- **rpm (Fedora):** `sudo dnf install make cmake gcc glew-devel glfw-devel libtheora-devel zlib-devel`
- **xbps (Void):** `sudo xbps-install make cmake gcc pkg-config glew-devel glfw-devel libtheora-devel zlib-devel`
- Your favorite package manager here, [make a pull request](https://github.com/RSDKModding/RSDKv5-Decompilation/fork) (also update [Mania](https://github.com/RSDKModding/Sonic-Mania-Decompilation)!)

#### (make sure to [install GL shaders!](FAQ.md#q-why-arent-videosfilters-working-while-using-gl))

### Switch
[Setup devKitPro](https://devkitpro.org/wiki/Getting_Started), then run the following:
- `(dkp-)pacman -Syuu switch-dev switch-libogg switch-libtheora switch-sdl2 switch-glad`

Finally, follow the [compilation steps below](#compiling) using `-DCMAKE_TOOLCHAIN_FILE=/opt/devkitpro/cmake/Switch.cmake` as arguments for `cmake -B build`.

#### (make sure to [install GL shaders!](FAQ.md#q-why-arent-videosfilters-working-while-using-gl))

### Android
Follow the android build instructions [here.](./dependencies/android/README.md)

## Compiling
After downloading libtheora, unzip it in `dependencies/all` as 'libtheora'.

## Compiling for Emscripten

> [!NOTE]  
> This fork does *not* run standalone! If you want to host your own build, you will need to build the [RSDK-Library Engine Manager](https://github.com/Jdsle/RSDK), or develop your own interface.

> Also you will need to replace RSDKv5U.js/wasm in the public/modules folder if you're using the [RSDK-Library Engine Manager](https://github.com/Jdsle/RSDK), if you want prebuilt versions go here: https://github.com/ant9012/rsdk-library-fork/tree/main/public/modules and for playable prebuilts if you simply want to play this web port, go here: https://ant9012.github.io/rsdk-library-fork

Compiling is as simple as typing the following in the root repository directory:
```
emcmake cmake -B build
cmake --build build --config release
```

## Compiling for your native platform

Compiling is as simple as typing the following in the root repository directory:
```
cmake -B build 
cmake --build build --config release
```

The resulting build will be located somewhere in `build/` depending on your system.

The following cmake arguments are available when compiling:
- Use these by adding `-D[flag-name]=[value]` to the end of the `emcmake cmake -B build` command. For example, to build with `RETRO_DISABLE_PLUS` set to on, add `-DRETRO_DISABLE_PLUS=on` to the command.

### RSDKv5 flags
- `RETRO_REVISION`: What revision to compile for. Takes an integer, defaults to `3` (RSDKv5U).
- `RETRO_DISABLE_PLUS`: Whether or not to disable the Plus DLC. Takes a boolean (on/off): build with `on` when compiling for distribution. Defaults to `off`.
- `RETRO_MOD_LOADER`: Enables or disables the mod loader. Takes a boolean, defaults to `on`.
- `RETRO_MOD_LOADER_VER`: Manually sets the mod loader version. Takes an integer, defaults to the current latest version.
- `RETRO_DISABLE_LOG`: Disables the log. Not recommended unless it impacts performance. Takes a boolean, defaults to `off`.
- `RETRO_SUBSYSTEM`: *Only change this if you know what you're doing.* Changes the subsystem that RSDKv5 will be built for. Defaults to the most standard subsystem for the platform.

# Getting this to work on custom interfaces
To get this web port to work, you need to change your CORS policy on how you serve the port itself, that being your own interface. This is required as libtheora/theoraplay requires multiple threads to work, this is an issue as modern browsers **WILL BLOCK MULTI-THREADING BY DEFAULT.** If you dont the port will not launch, so don't open an issue saying that the port wont open, as most likely you forgot to set the required http response headers: 
```http
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```
You might be asking, "HOW TF AM I SUPPOSED TO DO THIS???????"
If so here are some simple solutions:

## Setting these in whatever interface you're using to launch the port
Since you're using a custom interface, it is still **STUPID** easy to setup.

All *you* need to do is to get this: https://raw.githubusercontent.com/gzuidhof/coi-serviceworker/refs/heads/master/coi-serviceworker.js (right-click the link and click on Save As... ), and drop it in the root directory where you are launching the port, and set this where your ```<head>``` of the .html file you're using to launch the port itself (aka where you're launching the RSDKv3.js/.wasm files):

```html
<head>
    <script src="coi-serviceworker.js"></script>
    <!-- Your other meta tags and scripts go here -->
</head>
```
and after that, you're good to go!


# Getting Shaders to work on web

Extract your Data.rsdk from Sonic Mania using [RetroED](https://github.com/RSDKModding/RetroED) which you can download [here](https://github.com/RSDKModding/RetroED/releases/latest) and extract it (see [here](https://gamebanana.com/tuts/16686#H1_1)), and then download this repo using the download zip button in the Code < > dropdown menu. Copy RSDKv5/Shaders to the root of your Data/ folder (not the **CONTENTS** of it but just copy the folder itself). You can upload the Data/ folder as-is, but it isnt against the rules to pack it into a Data.rsdk again. After that, you're good!


# Contact:
Join the [Retro Engine Modding Discord Server](https://dc.railgun.works/retroengine) for any extra questions you may need to know about the decompilation or modding it.
