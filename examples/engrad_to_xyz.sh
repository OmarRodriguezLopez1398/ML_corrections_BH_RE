#!/bin/bash

# Constante de conversión: 1 bohr = 0.529177 angstrom
bohr_to_angstrom=0.529177

# Recorre todos los archivos .engrad
find . -type f -name "*.engrad" | while read -r file; do
    # Extraer número de átomos
    natoms=$(awk '/# Number of atoms/{getline; getline; print $1}' "$file")

    # Extraer coordenadas (luego del encabezado '# The atomic numbers and current coordinates in Bohr')
    coords=$(awk '
        /# The atomic numbers and current coordinates in Bohr/ {found=1; next}
        found && NF==4 {print}
    ' "$file")

    # Crear nombre del archivo .xyz
    xyz_file="${file%.engrad}.xyz"

    # Escribir archivo .xyz
    {
        echo "$natoms"
        echo ""
        # Procesar cada línea de coordenadas
        echo "$coords" | while read -r Z x y z; do
            # Convertir número atómico a símbolo
            case $Z in
                1)  sym="H" ;;
                6)  sym="C" ;;
                7)  sym="N" ;;
                8)  sym="O" ;;
                *)  sym="X$Z" ;;  # Desconocido
            esac

            # Convertir coordenadas a angstroms
            xA=$(awk -v v="$x" -v f="$bohr_to_angstrom" 'BEGIN{printf "%.6f", v*f}')
            yA=$(awk -v v="$y" -v f="$bohr_to_angstrom" 'BEGIN{printf "%.6f", v*f}')
            zA=$(awk -v v="$z" -v f="$bohr_to_angstrom" 'BEGIN{printf "%.6f", v*f}')

            echo "$sym  $xA  $yA  $zA"
        done
    } > "$xyz_file"

    echo "Convertido: $file -> $xyz_file"
done

