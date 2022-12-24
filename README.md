https://user-images.githubusercontent.com/77230051/192085179-8b7fde87-57d5-4c5f-ad3e-adda61d22ea6.mp4

<br>
<p align="center">
    <a href="https://github.com/festivize/PrimoToon"><img src="https://user-images.githubusercontent.com/77230051/209431459-32fcd906-57c3-4bba-ba4e-5092ab36a964.png" alt="PrimoToon"/></a>
</p><br>

<p align="center">
    <a href="https://github.com/festivize/PrimoToon/blob/main/LICENSE"><img alt="GitHub license" src="https://img.shields.io/github/license/festivize/PrimoToon?style=for-the-badge"></a><br>
    <a href="https://github.com/festivize/PrimoToon/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/festivize/PrimoToon?style=for-the-badge"></a>
    <a href="https://discord.gg/85rP9SpAkF"><img alt="Discord" src="https://img.shields.io/discord/894925535870865498?style=for-the-badge"></a>
    <a href="https://github.com/festivize/PrimoToon/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/festivize/PrimoToon?style=for-the-badge"></a>
</p>

---

<h2 align="center">This README.md is WIP</h2>

---

## Video guide
[![Video guide](https://pbs.twimg.com/media/FkrhGJ7UUAIcV2w?format=jpg)](https://youtu.be/KFkJuNbt6yo)

## Temporary text guide
Make sure **ALL** your textures <u>**EXCEPT**</u> the ramp textures have *Texture Type* set to **Default**, *Compression* set to **High Quality**, and *Generate Mip Maps* **ticked**. The ramp textures should have no compression and mip mapping to prevent artifacting and precision issues.

All ramp textures should have *Wrap Mode* changed from Repeat to **Clamp**. The specular ramp texture must have the *sRGB (Color Texture)* property **unticked**.

All lightmaps, normal maps, and the face shadow texture should have their *sRGB (Color Texture)* property **unticked**. Keep in mind with what I've said earlier, the normal map should have the *Texture Type* set to **Default**. **IGNORE THE NORMAL MAP TEXTURE TYPE!**

For weapon dissolve/VFX, you must have these common textures:
- *Eff_WeaponsTotem_Grain_00.png* ---> **Weapon Pattern**
- *Eff_WeaponsTotem_Dissolve_00.png* ---> **Weapon Dissolve**
- *Eff_Gradient_Repeat_01.png* ---> **Scan Pattern**

All of the above textures should have *sRGB (Color Texture)* **unticked** and the dissolve texture's *Wrap Mode* set to **Clamp**. Both the dissolve and scan line *(Eff_Gradient_Repeat_01.png)* textures should have no compression and mip mapping.

Unity projects in the Built-in Rendering Pipeline default to the Gamma option for color management. This is **not** what Genshin Impact uses. To avoid color inaccuracy, make sure that the *Color Space* is set to **Linear** in the [*Project Settings*](https://docs.unity3d.com/Manual/LinearRendering-LinearOrGammaWorkflow.html).

Genshin Impact models have custom tangents within them. If your model is properly ripped, you'll want to make sure that the *Tangents* property is set to **Import** instead of the default Calculate Mikktspace. If your model does not have the custom tangents, you can easily regenerate them with this [script](https://github.com/festivize/PrimoToon/blob/main/Assets/Scripts/AverageNormals.cs).

## Contact / Issues
- [Discord server](https://discord.gg/85rP9SpAkF)
- [Twitter](https://twitter.com/festivizing)
- Either contact me or [create an issue](https://github.com/festivize/PrimoToon/issues/new/choose) for any problems that may arise.
- Please don't bother me for assets.

## Rules
- The [GPL-3.0 License](https://github.com/festivize/Cheddar/blob/main/LICENSE) applies.
- If you use this shader as is in avatars for VRChat, renders, animations or any form of medium that does not directly modify the shader, I'd appreciate being credited - **you don't have to do it though.**
- If you use this shader as the main reference for your own shader, please give credit where it's due.
- In compliance with the license, you are free to redistribute the files as long as you attach a link to the source repository.

## Contributing
My code is most likely horrible given that this is my first programming project so I'd appreciate any help! Just create a pull request and I'll do my best to get to it ^^

## Special thanks
All of this wouldn't be possible if it weren't for:
- Arc System Works
- miHoYo
- [Aerthas Veras](https://github.com/Aerthas/) 
- [Manashiku](https://github.com/Manashiku/)
- The folks over at [知乎专栏](https://zhuanlan.zhihu.com/)
- JTAOO
- [Unari](https://twitter.com/UnariVR/)
- The VRC Shader Development Discord
- [Razmoth](https://github.com/Razmoth/)
- [radioegor146](https://github.com/radioegor146/)
- [Mero](https://github.com/GrownNed/)
- [Lunatic](https://github.com/lunaticwhat/)

## Disclaimer
This shader isn't meant to be 100% accurate - what I only aim for is to replicate the in-game looks to the best of my ability. Some calculations are exactly how the game does things, some are my own thrown into the mix.

While the shader is developed primarily for datamined assets, this repository does not endorse datamining in any way whatsoever and will never directly provide the assets nor tools in extracting from game files.

## Since you've read this far...
Using this shader is completely **free** if it's not already evident from the license BUT - if and only if you have something to spare and would like to support me, then you can do so on my Ko-fi [here](https://ko-fi.com/festivity). I appreciate every tip and each one motivates me to keep on improving the shader.
