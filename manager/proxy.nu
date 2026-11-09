# 默认 NO_PROXY 绕过列表：本机、私有网段、链路本地、CGNAT、常见内网/集群域名后缀
const no_proxy = 'localhost,127.0.0.0/8,::1,0.0.0.0,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16,100.64.0.0/10,.local,.localhost,.internal,.lan,.home.arpa,.svc,.cluster.local'

# 管理 NO_PROXY 绕过列表。
#
# 从管道接收 list<string> 作为绕过项；不接管道时返回当前 NO_PROXY 拆分后的列表。
# 默认替换现有 NO_PROXY；加 --append 则与现有列表合并去重。
#
# 示例：
#   ['foo.local' 'bar.internal'] | proxy bypass --append --verbose
#   proxy bypass
export def --env 'proxy bypass' [
  --append    # 追加到现有 NO_PROXY，而不是替换
  --verbose   # 打印最终生成的 NO_PROXY
]: [list<string> -> list<string>, nothing -> list<string>] {
  let input = $in

  let sys_ls: list<string> = match ($env.NO_PROXY? | describe) {
    'nothing' => []
    'string'  => ($env.NO_PROXY | split row ',')
    _ => (error make {msg: 'Unexpected Type from $env.NO_PROXY'})
  }

  let user_ls: list<string> = match ($input | describe) {
    'nothing'      => ( return $sys_ls )
    'list<string>' => $input
    _ => (error make {msg: 'Unexpected Type $in'})
  }

  let final_no_proxy = if $append {
    $sys_ls | append $user_ls | uniq
  } else {
    $user_ls | uniq
  }

  if $verbose {
    print $"NO_PROXY: ($final_no_proxy)"
  }

  $env.NO_PROXY = $final_no_proxy | str join ','
  $final_no_proxy
}

# 设置代理环境变量，并默认设置 NO_PROXY 绕过列表。
#
# 设置 ALL_PROXY / HTTP_PROXY / HTTPS_PROXY，
# 并默认设置 NO_PROXY 绕过列表（可用 --no-bypass 跳过）。
#
# 示例：
#   proxy set
#   proxy set -P socks5 -H 127.0.0.1 -p 1080
#   proxy set --no-bypass --verbose
export def --env 'proxy set' [
  --protocol(-P): string = "http"      # 代理协议，例如 http、socks5
  --host(-H): string = "localhost"     # 代理主机
  --port(-p): int = 10808              # 代理端口
  --no-bypass                          # 不自动设置默认 NO_PROXY 绕过列表
  --verbose                            # 输出 NO_PROXY 等详细信息
]: nothing -> nothing {
  let s = $'($protocol)://($host):($port)'

  $env.ALL_PROXY   = $s
  $env.HTTP_PROXY  = $s
  $env.HTTPS_PROXY = $s

  if $verbose {
    print $"Proxy Server: ($s)"
  }

  # 默认设置 bypass；只有显式传入 --no-bypass 才跳过
  if not $no_bypass {
    $env.NO_PROXY = $no_proxy

    if $verbose {
      print $"NO_PROXY: ($no_proxy)"
    }
  }
}

# 清除当前环境中的代理相关变量。
#
# 清除 ALL_PROXY / HTTP_PROXY / HTTPS_PROXY / NO_PROXY。
#
# 示例：
#   proxy unset
export def --env 'proxy unset' []: nothing -> nothing {
  hide-env ALL_PROXY
  hide-env HTTP_PROXY
  hide-env HTTPS_PROXY
  hide-env NO_PROXY
}

# proxy 命令族入口，显示帮助信息。
#
# 示例：
#   proxy
#   help proxy
export def proxy []: nothing -> nothing {
  help proxy
}
