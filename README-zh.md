# Scripts

一些帮助开发自动化的scripts和工具

## [python打包脚本](./ios-pakging/)

最初主要用于打ad-hoc的包

## [修改png文件的md5值](./png-md5-change/)

用来修改XCode工程中的各种资源文件（png/jpg/mp3/m4a...）的md5值，而不改变文件本身的内容

## [重命名类、源文件、资源文件和本地化keys](./Renamer)

Renamer是一个用swift写的命令行工具。它目前能够用于重命名项目中的类、源文件、资源文件等等。

- 类重命名: 将原来的类的前缀修改为新的前缀、替换所有引用、同时重命名该的的文件名; 另外，也可以轻松修改这部分功能来适应自己的需求。
- 所有的资源文件重命名：在assets文件夹中的资源文件名称是和assets文件夹下.imageset文件夹名称相关联的。有的时候png图的名字和.imageset不对应。Renamer可以帮助重命名所有的.imageset文件夹和其中的所有资源文件名称
- 所有的本地化keys：修改所有本地化的keys；同时修改他们在代码中的引用

