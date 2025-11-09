def get_pos [m:int, n:int, x_raw:int, y_raw:int] {
    let x0 = $m // 2;
    let y0 = $n // 2;
    return [($x_raw - $x0), ($y0 - $y_raw)]
}

def pos2char [x:int, y:int] {
    match [$x, $y] {
        [0, 0] => { '+' }
        [_, 0] => { '-' }
        [0, _] => { '|' }
        [$a, $b] if $a > 0 and $b > 0  => { if $a == $b {'/'} else if $a > $b {'B'} else {'A'}  }
        [$a, $b] if $a > 0 and $b < 0  => { if $a == 0 - $b {'\'} else if $a > 0 - $b {'C'} else {'D'} }
        [$a, $b] if $a < 0 and $b > 0  => { if 0 - $a == $b {'\'} else if 0 - $a > $b {'G'} else {'H'} }
        [$a, $b] if $a < 0 and $b < 0  => { if $a == $b {'/'} else if $a > $b {'E'} else {'F'} }
    }
}

export def mkmap [x:int, y:int , m:int = 5, n:int = 5] {
    let x_range = ($x - ($m - 1) // 2)..($x + $m // 2);
    let y_range = ($y + ($n - 1) // 2)..($y - $n // 2);

    $y_range
        | each { |i| $x_range | each { |j| pos2char $j $i }}
}

export def print_map [m:int, n:int] {
    mkmap 0 0 $m $n
        | each { str join '' }
        | str join "\n"
}

export def print_gps [x:int, y:int] {
    mkmap $x $y 5 5
        | each {str join ''}
        | str join "\n"
}


