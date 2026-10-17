#!/bin/bash
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/splash\.jpeg}/\includegraphics[width=2.5cm,keepaspectratio]{assets\/splash.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/icon\.png}/\includegraphics[width=2cm,keepaspectratio]{assets\/icon.png}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/home_empty\.jpeg}/\includegraphics[width=4cm,keepaspectratio]{assets\/home_empty.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/home_today\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/home_today.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/home_marked_geldim\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/home_marked_geldim.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/home_marked_gelmedim\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/home_marked_gelmedim.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/home_all_courses\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/home_all_courses.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/rights_critical\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/rights_critical.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/home_swipe\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/home_swipe.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/calendar_dots\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/calendar_dots.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/calendar_day\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/calendar_day.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/calendar_holiday\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/calendar_holiday.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/exam_calendar\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/exam_calendar.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/exam_notes\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/exam_notes.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/add_course\.jpeg}/\includegraphics[width=4cm,keepaspectratio]{assets\/add_course.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/exam_add\.png\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/exam_add.png.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/exam_detail\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/exam_detail.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/profile\.jpeg}/\includegraphics[width=4cm,keepaspectratio]{assets\/profile.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/settings\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/settings.jpeg}/g' main.tex
sed -i 's/\includegraphics\[\([^]]*\)\]{assets\/settings_term\.jpeg}/\includegraphics[width=3.5cm,keepaspectratio]{assets\/settings_term.jpeg}/g' main.tex
echo "Tüm includegraphics satırları güncellendi!"
