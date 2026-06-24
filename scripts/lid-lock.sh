#!/bin/bash
LID_STATE="/proc/acpi/button/lid/LID/state"

while true; do
    until grep -q "closed" "$LID_STATE" 2>/dev/null; do
        sleep 2
    done

    hyprlock --grace 0

    while grep -q "closed" "$LID_STATE" 2>/dev/null; do
        sleep 2
    done
done
