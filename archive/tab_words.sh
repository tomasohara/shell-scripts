#! /usr/local/bin/tcsh -f

count_it.pe -i "\W([\wáéíóúñüÁÉÍÓÚÑÜ]+)\W" $*
