# fduthesis

复旦大学学位论文 LaTeX 模板的数学增强维护分支，公开类名为 `fduthesis` 和 `fduthesis-en`。
当前中文实现保留数学定理环境、定理计数器安全修复和 `style/spec = 2026` 配置。

## 源码与生成文件

- `source/fduthesis-math.dtx` 是当前中文类的维护源码。
- `source/fduthesis.dtx` 管理生成入口、英文类和定义文件，中文生成入口已关联数学增强源。
- 根目录的 `.cls`、`.def` 和 `fdulogo.sty` 为随仓库提供的运行文件。
- `l3build unpack` 重新生成运行文件；`python3 tests/check-standalone.py` 检查生成结果与独立构建。

校徽、校名和 2026 年引用样式已随项目提供，无需访问私有的 `fduTeX`。
`install-unix.sh` 和 `install-win.bat` 使用相同源码生成 `thesis/` 示例目录。
模板的字体设置可按操作系统选择；自动检查采用 Fandol 与 Latin Modern。
2026 年规范说明见 `docs/2026-论文规范适配开发文档.md`。
原项目的 LPPL 许可和版权声明保持，详见 `LICENSE` 及源文件。

## 独立仓库维护

本目录由独立仓库 [`xkwxdyy/fduthesis`](https://github.com/xkwxdyy/fduthesis) 维护。
在本目录执行 `git commit` 和 `git push`，操作对象均为本项目。
`fduTeX` 仅通过 Git 子模块记录本项目的版本，不直接维护本项目源码。

首次在总项目中维护子模块时，先确认当前分支为 `main`；首次递归检出可能处于分离的提交状态。
先推送本项目，再按需更新 `fduTeX` 记录的子模块版本。
个人材料、活动资产和编译产物继续保留在本地，不因迁移而删除。

公开仓库不纳入 `applications/`、个人参考材料或本地分享压缩包。
