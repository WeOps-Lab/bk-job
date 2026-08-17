# bk-job 第三方组件漏洞修复报告

## 1. 报告信息

| 项目 | 内容 |
| --- | --- |
| 项目名称 | bk-job |
| 代码分支 | `weops` |
| 报告日期 | 2026-08-17 |
| 漏洞来源 | `job漏洞.xlsx` |
| 修复原则 | 最小化修改、不改业务逻辑、不启动或重启现有服务 |
| 当前状态 | 代码已修改并完成本地构建验证，尚未发布 |

## 2. 修复结论

漏洞清单共包含 7 项，其中 1 项 MySQL 漏洞在原清单中已经标记为“已修复”，其余 6 项为待处理项。

本次通过修改 bk-job 的统一依赖管理配置，已解决其中 5 项：

- CVE-2021-22044：Spring Cloud OpenFeign 核心组件漏洞。
- CVE-2026-42578：Netty Proxy Handler 漏洞。
- CVE-2026-42579：Netty DNS Codec 漏洞。
- CVE-2026-45674：Netty DNS Resolver 漏洞。
- CVE-2026-47691：Netty DNS Resolver 漏洞。

剩余 CVE-2025-24970 位于 Elasticsearch 和 ZooKeeper 的安装目录，不属于 bk-job 应用 JAR 的依赖，需在对应基础镜像或中间件部署中单独修复。

## 3. 漏洞影响及处置情况

| CVE | 原组件版本 | 影响范围 | 修复版本/处置 | 状态 |
| --- | --- | --- | --- | --- |
| CVE-2021-22044 | `spring-cloud-openfeign-core 3.0.3` | job-backup、job-logsvr、job-crontab、job-analysis、job-execute、job-manage、job-gateway | 定向升级至 `3.0.5` | 已修复 |
| CVE-2026-42579 | `netty-codec-dns 4.1.65.Final` | job-gateway | 升级至 `4.1.135.Final` | 已修复 |
| CVE-2026-42578 | `netty-handler-proxy 4.1.65.Final` | job-gateway | 升级至 `4.1.135.Final` | 已修复 |
| CVE-2026-45674 | `netty-resolver-dns 4.1.65.Final` | job-gateway | 升级至 `4.1.135.Final` | 已修复 |
| CVE-2026-47691 | `netty-resolver-dns 4.1.65.Final` | job-gateway | 升级至 `4.1.135.Final` | 已修复 |
| CVE-2025-24970 | `netty-handler 4.1.94.Final` | Elasticsearch、ZooKeeper 安装目录 | 升级对应中间件镜像；不在 bk-job 中直接替换 JAR | 待单独处理 |
| CVE-2023-22102 | Oracle MySQL | 原清单已标记修复 | 无需本次处理 | 已修复 |

## 4. 根因分析

### 4.1 OpenFeign 漏洞

项目使用的 Spring Cloud 依赖管理默认解析出 `spring-cloud-openfeign-core 3.0.3`。该版本受 CVE-2021-22044 影响。

本次没有升级整个 Spring Cloud BOM，仅对存在漏洞的 OpenFeign 核心模块进行定向版本覆盖，从而降低对注册发现、网关、配置中心等其他 Spring Cloud 组件的影响。

### 4.2 Netty 漏洞

项目原有统一 Netty 版本配置，但依赖集合没有包含以下由网关间接引入的模块：

- `netty-codec-dns`
- `netty-codec-socks`
- `netty-handler-proxy`
- `netty-resolver-dns`
- `netty-resolver-dns-native-macos`

因此，这些模块没有受到项目统一版本约束，最终回退到 Spring Boot/Spring Cloud 依赖管理中的 `4.1.65.Final`，形成同一应用内 Netty 模块版本不一致的问题，并触发漏洞扫描。

本次将遗漏模块加入统一依赖集合，并把 Netty 统一至 `4.1.135.Final`，同时解决版本不一致和 4 项 Netty 漏洞。

### 4.3 Elasticsearch/ZooKeeper 漏洞

CVE-2025-24970 的扫描路径位于 Elasticsearch 和 ZooKeeper 自身的安装目录，不在 bk-job 构建产物中。直接替换中间件目录中的单个 Netty JAR 可能造成二进制兼容风险，因此本次没有对其进行非受控替换。

建议通过升级 Elasticsearch/ZooKeeper 产品版本或基础镜像，使其中的 `netty-handler` 升级到安全版本，并按照中间件官方兼容矩阵验证。

## 5. 代码修改

修改文件：`src/backend/build.gradle`

主要变更：

1. 将统一 Netty 版本由 `4.1.124.Final` 升级至 `4.1.135.Final`。
2. 增加 `springCloudOpenFeignVersion = 3.0.5`，仅覆盖 OpenFeign 核心模块。
3. 将 DNS、SOCKS、Proxy 和 Resolver 相关 Netty 模块加入统一版本管理。
4. 未修改业务代码、接口、数据库结构、配置格式和服务启动方式。

变更统计：

```text
src/backend/build.gradle | 17 +++++++++++++----
1 file changed, 13 insertions(+), 4 deletions(-)
```

## 6. 本地验证

### 6.1 验证环境

| 项目 | 内容 |
| --- | --- |
| JDK | Amazon Corretto 1.8.0_382 |
| 数据库 | 临时 MySQL 5.7 容器 |
| 数据初始化 | 使用项目正式数据库迁移脚本初始化 6 个业务库 |
| 构建命令 | `./gradlew clean build -x test`，并传入本地 MySQL 连接参数 |

临时数据库包含：

- `job_analysis`
- `job_backup`
- `job_crontab`
- `job_execute`
- `job_file_gateway`
- `job_manage`

验证结束后，临时 MySQL 5.7 容器已停止并删除。

### 6.2 构建结果

```text
BUILD SUCCESSFUL in 1m 31s
293 actionable tasks: 291 executed, 2 up-to-date
```

完整构建覆盖了 JOOQ 代码生成、Java 编译、资源处理和 Spring Boot JAR 打包。构建过程中出现的 Gradle 隐式任务依赖及废弃 API 警告为项目原有警告，没有导致构建失败，也不是本次依赖调整引入的编译错误。

### 6.3 构建产物核验

对以下受影响服务的最终 Spring Boot JAR 进行了依赖清单检查：

- `job-backup-1.0.0.jar`
- `job-logsvr-1.0.0.jar`
- `job-crontab-1.0.0.jar`
- `job-analysis-1.0.0.jar`
- `job-execute-1.0.0.jar`
- `job-manage-1.0.0.jar`
- `job-gateway-1.0.0.jar`

核验结果：

- 7 个服务包中的 `spring-cloud-openfeign-core` 均为 `3.0.5`。
- job-gateway 中的 `netty-codec-dns`、`netty-handler-proxy`、`netty-resolver-dns` 均为 `4.1.135.Final`。
- job-gateway 内 Netty 核心、HTTP、DNS、SOCKS、Proxy、Resolver 和 Transport 模块均已统一为 `4.1.135.Final`。
- 所有最终发布 JAR 均未检出 `spring-cloud-openfeign-core-3.0.3.jar`。
- 所有最终发布 JAR 均未检出表中涉及的 Netty `4.1.65.Final` 漏洞模块。
- `git diff --check` 通过，未发现空白符错误。

### 6.4 服务影响

本次验证没有启动、停止或重启任何现有 bk-job 服务，也没有连接或修改现有业务数据库。所有数据库操作均发生在本地临时 MySQL 5.7 容器中。

测试任务使用 `-x test` 跳过，因为完整测试依赖 Consul、Redis 等外部服务。本次已经完成编译和打包级验证，上线前仍建议在测试环境执行网关转发、服务间 Feign 调用和作业下发的冒烟测试。

## 7. 风险评估

| 风险项 | 评估 | 控制措施 |
| --- | --- | --- |
| 业务逻辑变化 | 低 | 未修改任何业务代码 |
| OpenFeign 兼容性 | 低 | 仅进行同一 3.0.x 维护版本升级 |
| Netty 兼容性 | 低至中 | 同一 4.1.x 长期维护分支升级；所有模块统一版本；完整编译和打包通过 |
| 数据库影响 | 无 | 未修改数据库结构和业务数据 |
| 在线服务影响 | 无 | 本地验证期间未操作现有服务 |
| 中间件遗留漏洞 | 需跟进 | Elasticsearch/ZooKeeper 通过镜像或产品升级单独修复 |

## 8. 上线与回滚建议

### 8.1 上线建议

1. 在测试环境重新构建部署，不建议直接复用历史缓存 JAR。
2. 优先对 job-gateway 做单实例滚动更新，验证健康检查、路由转发和服务发现。
3. 验证各服务间 Feign 调用、作业执行、日志回传和文件分发。
4. 冒烟测试通过后，再滚动更新其余服务，避免全量同时重启。
5. 部署完成后对运行镜像重新执行漏洞扫描，确认应用 JAR 中旧版本已消失。

### 8.2 回滚建议

本次仅涉及依赖版本管理，可直接回滚到上一版本应用包，不涉及数据库回滚。建议发布前保留上一版本镜像和部署配置，在健康检查或核心调用异常时按服务逐个回滚。

## 9. 遗留事项

1. 对 Elasticsearch 和 ZooKeeper 所在镜像进行资产确认，定位其具体产品版本和镜像来源。
2. 选择包含安全版 Netty 的官方中间件版本，不建议手工替换单个 Netty JAR。
3. 在测试环境完成索引读写、集群状态、ZooKeeper 会话和节点监听验证后，再滚动升级中间件。
4. 升级完成后重新扫描并关闭 CVE-2025-24970。

## 10. 参考公告

- [CVE-2021-22044 / GHSA-pf94-6v2v-cm3j](https://github.com/advisories/GHSA-pf94-6v2v-cm3j)
- [CVE-2026-42579 / GHSA-cm33-6792-r9fm](https://github.com/advisories/GHSA-cm33-6792-r9fm)
- [CVE-2026-42578 / GHSA-45q3-82m4-75jr](https://github.com/advisories/GHSA-45q3-82m4-75jr)
- [CVE-2026-45674 / GHSA-676x-f7gg-47vc](https://github.com/advisories/GHSA-676x-f7gg-47vc)
- [CVE-2026-47691 / GHSA-5pvg-856g-cp85](https://github.com/advisories/GHSA-5pvg-856g-cp85)
- [CVE-2025-24970 / GHSA-4g8c-wm8x-jfhw](https://github.com/advisories/GHSA-4g8c-wm8x-jfhw)
