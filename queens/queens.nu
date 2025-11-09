export def get-next-col [qs:list<int>, width:int] {
    let len = $qs | length
    $qs
    | enumerate
    | par-each  {|x| 1..$width
        | where {$in not-in [$x.item ($x.item - ($len - $x.index)) ($x.item + ($len - $x.index))]} }
    | reduce {|x, acc| $acc | where { $in in $x } }
}

def gen-queen [qs:list<int>, width:int] {
    let len = $qs | length

    if ($len == $width) {
        return [ $qs ]
    }

    let next = get-next-col $qs $width
    if ($next | is-empty) {
        return []
    }

    $next
    | each { |x| $qs | append $x }
    | each { |it| gen-queen $it $width }
    | where { |e| $e | is-not-empty }
    | flatten
}

export def init-queen [n:int] {
    1..$n | par-each { gen-queen [$in] $n } | flatten
}
