#!/bin/bash
hyprlock --grace 0 &
sleep 1
systemctl suspend
