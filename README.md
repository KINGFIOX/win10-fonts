# win10-fonts

把从 Windows 复制出来的字体文件（放在 `win10/` 目录）打成 Nix flake 包，方便本机安装和对外分发。

## 目录约定

- 把字体文件放在 `win10/`，支持：`.ttf` `.ttc` `.otf` `.otc` `.fon` `.fnt`
- 文件扩展名大小写都可以

## 本地构建

```bash
nix build .#win10-fonts
```

构建后字体位于：

```bash
./result/share/fonts/truetype
```

## 临时试用

```bash
nix run .#default
```

会列出包内字体文件，方便确认是否打包成功。

## 作为 flake 依赖分发

在其他 flake 中引入：

```nix
inputs.win10-fonts.url = "github:KINGFIOX/win10-fonts";
```

然后使用以下任一方式：

- 包引用：`inputs.win10-fonts.packages.${pkgs.system}.win10-fonts`
- overlay：`inputs.win10-fonts.overlays.default`
- NixOS 模块：`inputs.win10-fonts.nixosModules.default`

## NixOS 示例

```nix
{
  inputs.win10-fonts.url = "github:<your-user>/win10-fonts";

  outputs = { self, nixpkgs, win10-fonts, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        win10-fonts.nixosModules.default
      ];
    };
  };
}
```
