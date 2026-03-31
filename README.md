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

**MAKE SURE TO FOLLOW THE INSTRUCTIONS FOR HOSTING THIS BELOW**

[Custom Interface instructions](#Getting-this-to-work-on-custom-interfaces)

[Shaders instructions](#Getting-Shaders-to-work-on-web)


# How to Build

This project uses [CMake](https://cmake.org/), a versatile building system that supports many different compilers and platforms. You can download CMake [here](https://cmake.org/download/). **(Make sure to enable the feature to add CMake to the system PATH during the installation if you're on Windows!)**

## Get the source code

In order to clone the repository, you need to install Git, which you can get [here](https://git-scm.com/downloads).

Clone the repo **recursively**, using:
`git clone --recursive --single-branch --branch web https://github.com/ant9012/RSDKv5-Decompilation-wasm.git`

If you've already cloned the repo, run this command inside of the repository:
```git submodule update --init```

## Getting dependencies

The only dependency that you need is libtheora, which you can find at: https://xiph.org/downloads/. Any other dependency will be handled by Emscripten.

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

For shaders to work on web follow the instructions here: https://rsdkmodding.com/Guides/RSDKv5/Decompilation/ShadersSetup/

#### HOWEVER

Instead of grabbing the RSDKv5/Shaders from the [official repo](https://github.com/RSDKModding/RSDKv5-Decompilation) grab them from here, as there are some changes I needed to make in order for the shaders to look properly.

You can also extract your Data.rsdk from [RetroED](https://github.com/RSDKModding/RetroED), using the RSDK Unpacker, select your Data.rsdk by clicking on Select DataPack, then it will give you a list of .txt files. Make sure to click on the RSDKv5 one. Now click on Export DataPack and set the directory where you want the Data folder to be, and now there will be a Data Folder and add the Shaders folder in there in the root of the Data foler.

### How to do such a feat
Extract your Data.rsdk using [RetroED](https://github.com/RSDKModding/RetroED) and just plop the RSDKv5/Shaders folder in there.


# Contact:
Join the [Retro Engine Modding Discord Server](https://dc.railgun.works/retroengine) for any extra questions you may need to know about the decompilation or modding it.
