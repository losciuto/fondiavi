#!/bin/bash

# fonde due avi in un unico avi

cd /media/root

# finestra principale
input=$(yad --title="Fusione di due AVI" --center --borders="20" --width="550" --separator=","  2> /dev/null \
        --form \
        --field="AVI 1":SFL "$avi1" \
        --field="AVI 2":SFL "$avi2" \
        --field="AVI Destinazione\n(<i>output</i>)":SFL "$avi3" \
        --field="Elimina AVI (Se vistato, elimina i file AVI 1 e AVI 2).":CHK "$elim" \
        --button="gtk-cancel:1" \
        --button=" Procedi!iconok.png:2"  \
2>/dev/null
);return_code=$?

# split della stringa
avi1="$(cut -d',' -f1 <<<"$input")"
avi2="$(cut -d',' -f2 <<<"$input")"
avi3="$(cut -d',' -f3 <<<"$input")"
elim="$(cut -d',' -f4 <<<"$input")"

# alternative di split per più caratteri
# IFS=$'\n' read -rd '' -a stringa <<<"$input"
if [ "$elim" = "TRUE" ]; then
stringa="ATTENZIONE!! Prevista cancellazione dei file:
'$avi1' e
'$avi2

"
fi

stringa="$stringa
mencoder -ovc copy -oac copy 
'$avi1'
'$avi2'
-o '$avi3'
"

# finestra di controllo
[[ "$return_code" -eq "2" ]] && { printf "%s\n" "$stringa"| yad --text-info --width="550" --height="400" --wrap --title="Conferma dati" \
        --button="gtk-cancel:1" \
        --button=" Conferma!iconok.png:2" \
2>/dev/null
};return_code=$?


# Se si è cliccata la conferma dello ricerca
if [ "$return_code" -eq "2" ]; then


        if [ "x$avi1" = "x" ]; then

                echo "Manca il primo AVI da fondere: AVI 1"

        fi
        if [ "x$avi2" = "x" ]; then

                echo "Manca il secondo AVI da fondere: AVI 2"

        fi
        if [ "x$avi3" = "x" ]; then

                echo "Manca l'AVI di destinazione (output)."

        fi
        if [ "x$avi1" = "x" ] ||  [ "x$avi2" = "x" ] || [ "x$avi3" = "x" ]; then
            echo "Parametri incoerenti...esco."
            exit 1
        else        
                echo "Procedo con la fusione degli avi ($stringa)..."

                cmd="mencoder -ovc copy -oac copy '$avi1' '$avi2' -o '$avi3'"

                if [ "$elim" = "TRUE" ]; then
                    cmd="$cmd && rm -i '$avi1' '$avi2'"
                fi
#               avvio degli script per la fusione degli avi
                echo $cmd # controllo
                eval exec $cmd
        fi
else
        echo "Fusione annullata."
fi
