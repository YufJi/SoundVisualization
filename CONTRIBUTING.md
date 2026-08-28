# 贡献

## 开发流程

1. Fork 或克隆仓库。
2. 创建功能分支。
3. 修改后运行：

```bash
swift test
./build-app.sh
```

4. 提交前请保持改动聚焦，并补充必要的测试或文档。

## 提交说明

建议使用简洁的祈使句，例如：

- `fix: stabilize menu bar rendering`
- `feat: add spectrum area visualization`
- `docs: clarify audio capture permission`

## 代码约定

- 保持 macOS 主线程负责 AppKit 渲染和状态项更新。
- 音频实时回调中避免分配、锁等待和 UI 操作。
- 可视化不得引入系统音量参数。
- 新用户可见行为需要同步更新 `README.md`。
