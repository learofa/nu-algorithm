const tokenPath = '~/.cache/jinrishici/token'

def get-token [] {
    http get 'https://v2.jinrishici.com/token' | get data
}

# 管理在线站点的 token。
export def "jinri token" [
    --flush
] {
    if not ($tokenPath | path expand | path exists) or $flush {
        $tokenPath | path expand | path dirname | each { |e| if not ($e | path exists) { mkdir $e } }
        get-token | save --force $tokenPath
    } 
    $tokenPath | path expand | open $in
}

def update-sentence [] {
    jinri token | http get --headers [X-User-Token $in] 'https://v2.jinrishici.com/sentence'
}

def get-sentence [
    flush: bool
] {
    if (($env | get --optional "shici" | is-empty)
        or $flush
        or ($env.shici | get data.cacheAt | into datetime | (date now) - $in > 10min)) {
        update-sentence
    } else {
        $env.shici
    }    
}

def parse-sentence [ result: record ] {
    let data: record = $result.data
    let content: string = $data | get content
    let origin: string = $data | get origin
    let title: string = $origin.title
    let dynasty: string = $origin.dynasty
    let author: string = $origin.author

    let color = "purple_bold"
    let color_content = $"(ansi $color)($content)(ansi reset)"
    let all_content = $origin.content | str replace $content $color_content | str join "\n"
    
    { title:$title, author:($dynasty + "-" + $author), content:$all_content  }
}


# 从在线站点的开放接口获取一首古诗。
export def --env "jinri shici" [
    --full   # print full gushi
    --json   # print by json
    --all    # print all info
    --simple # print simple sentence
    --flush  # force flush gushi
] {
    let result: record = get-sentence $flush
    if $result.status != "success" { return $result }
    $env.shici = $result

    if $all { return $result }

    let error_color = $env.config.color_config.shape_garbage
    
    $result
    | get --optional warning
    | print --stderr $"(ansi --escape $error_color)($in)(ansi reset)"
    
    if $json { return $result.data }

    let shici: record = parse-sentence $result

    if $full {
        $shici
    } else if $simple {
        $result | get data.content
    } else {
        $shici.content
    }
}


# 本工具依赖在线网站“今日诗词开放接口”，主要目的是为了方便在控制台中显示诗词。
# 通过 `jinri shici` 命令从在线网站获取古诗及相关信息，并保存在环境变量中。
export def jinri [] {
    help jinri
}
