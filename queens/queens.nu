def get-next-col [qs:list<int>, width:int] {
    let len = $qs | length
    $qs
    | enumerate
    | each  {|x| 1..$width
        | where {$in not-in [$x.item ($x.item - ($len - $x.index)) ($x.item + ($len - $x.index))]} }
    | reduce {|x, acc| $acc | where { $in in $x } }
}

def gen-queens [qs:list<int>, width:int] {
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
    | each { |it| gen-queens $it $width }
    | where { |e| $e | is-not-empty }
    | flatten
}

export def get-all-queens [n:int] {
    1..$n | par-each { gen-queens [$in] $n } | flatten
}
