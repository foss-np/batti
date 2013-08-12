#!/bin/bash

PRG=$(basename $0)
WD="$(dirname $0)"

#source "./path.config"
if [ $? != "0" ]; then
    echo "Error: conky-forever path not configured"
    exit
fi

function Usage {
    echo -e "Usage: \tbatti -g [1-7] [OPTIONS] -m [1-7] [OPTIONS]";
    echo -e "\t-g | --group\tGroup number 1-7"
    echo -e "\t-m | --mode\tDisplay type 1/2"
    echo -e "\t-h | --help\tDisplay this message"
    exit
}

# checking arguments
if [ $# -eq 0 ]; then
    Usage;
    exit 1;
fi

# mode1
function mode1 {
    sed -i 's/\(alignment\).*/\1 top_right/
        s/\(gap_x\).*/\1 70/
       ' $_cbatti

    echo -e "\n\${color 88aaff}Group $group: \\" >> $_cbatti
    echo "\${exec SGR=0 $PWD/main.sh -g $group -t}" >> $_cbatti
}


# mode2
function mode2 {
    sed -i 's/\(alignment\).*/\1 top_right/
        s/\(gap_x\).*/\1 70/
       ' $_cbatti

    echo -e "\n\${color 00aaff}Group $group:" >> $_cbatti
    echo "\${hr 2}" >> $_cbatti
    echo "\${color 88aaff}\${exec SGR=0 $PWD/main.sh -g $group}" >> $_cbatti
}


_cbatti=~/.conkyrc

# group=$1
# mode=$2

TEMP=$(getopt	-o	g:m:\
		--long group:mode\
		-n "conky_independent" -- "$@")

if [ $? != "0" ]; then exit 1; fi

eval set -- "$TEMP"

mode=1 group=1
while true; do
    case $1 in
	-g|--group) group=$2; shift 2;;
	-m|--mode) mode=$2; shift 2;;
	-h|--help) Usage; exit;;
	*) shift; break;;
    esac
done

echo "
# process
	total_run_times 0 #run conky forever
	background no #daemon

# position
	alignment middle_middle
	gap_x 0
	gap_y 0
	#maximum_width 350
	#minimum_size 350

# engine
	double_buffer yes #reduces flicker
	text_buffer_size 256 #performance
	update_interval 3600 #in sec
	no_buffers yes #Subtract from used memory
	imlib_cache_size 0 #Force images redraw on change.

# window manager
	own_window_class conky
	own_window_title conky-plug

	own_window_transparent yes
	own_window_argb_visual yes # no for semi transpancy
	own_window_argb_value 128

	own_window yes #required in nautilus
	own_window_type normal
	own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager

# window
	draw_borders no
	border_width 1
	draw_graph_borders yes
	draw_outline no
	draw_shades yes
	border_inner_margin 10

#conky console
	out_to_console no
	out_to_stderr no
	out_to_ncurses no
	extra_newline no

#sample
	cpu_avg_samples 2
	net_avg_samples 2


#xft?
	use_xft yes
	xftfont mono space:size=11
	override_utf8_locale yes
	xftalpha 0

# settings
	use_spacer right
	show_graph_scale no
	show_graph_range no
	pad_percents 0 #symbol spacing after numbers

# color
	default_color white
	default_shade_color black
	default_outline_color white

TEXT
# start your script here!" > $_cbatti
case $mode in
1)
	mode1;;
2)
	mode2;;
*)
	mode2;;
esac

killall conky
conky -q &
