#!/bin/bash

### le script principal du projet
### qui exécutera les modifications
### sur le fichier facture type


# gestion des arguments :

for arg in $@
do
	if [[ $arg =~ ^--help$ ]]
	then
		echo """Script pour automatiser la création de facture
		4 arguments sont attendus:
		-> le numéro de la facture: '-nf=[num_fact]'
		-> le montant journalier de la formation en euros: '-mj=[mont_jour]'
		-> la date de début de la formation: '-ddf=[date_deb_form]'
		   (le format doit être donné au format anglais année-mois-jour : 2000-01-01)
		-> le nombre de jour que dure la formation: '-nj=[nb_jour]'
		"""
		exit 2
	elif [[ $arg =~ ^-nf=([0-9]+)$ ]]
	then
		num_fact=${BASH_REMATCH[1]}
	
	elif [[ $arg =~ ^-mj=([0-9]{3})$ ]]
	then
		mont_jour=${BASH_REMATCH[1]}
	
	elif [[ $arg =~ ^-ddf=([0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|(1|2)[0-9]|3[01]))$ ]]
	then
		date_deb_form=${BASH_REMATCH[1]}
	
	elif [[ $arg =~ ^-nj=([0-9]+)$ ]]
	then
		nb_jour=${BASH_REMATCH[1]}
	
	else
		echo "erreur d'argument, consultez l'aide (--help)"
		exit 1
	fi
done

# echo """année: $(echo $date_deb_form | awk -F"-" '{print $1}')
# mois: $(echo $date_deb_form | awk -F"-" '{print $2}')
# jour: $(echo $date_deb_form | awk -F"-" '{print $3}')
# """

### on s'assure que tous les paramètres nécessaires ont bien été fournis

# if [ -e $num_fact ] || [ -e $mont_jour ] || [ -e $date_deb_form ] || [ -e nb_jour ]
# then
# 	echo "Il manque au moins un argument pour exécuter le script (consultez l'aide: --help)"
# 	exit 1
# fi


### unzip du fichier facture type et placement à l'intérieur

[ -d unziped_facure ] && rm -r unziped_facure   # on s'assure qu'un dossier avec le fichier unzipé n'est pas déjà présent
unzip facture_type.ods -d ./unziped_facture &>/dev/null
cd unziped_facture



### Modification du numéro de facture

sed -i -E "s/insérer numéro facture/$num_fact/" content.xml



### Modification du forfait journalier:

sed -i -E "s/insérer montant journalier/$mont_jour/" content.xml



### Modification du montant total

mont_tot=$(( nb_jour * mont_jour ))
sed -i -E "s/insérer montant total/$mont_tot/g" content.xml 



### Modification des dates

months=(Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre)

# date de création de la facture

ac=$( date +%Y ) ; mc=$( date +%m ) ; jc=$( date +%d )

sed -i -E "s/date création facture/$js ${months[$((mc-1))]} $ac/" content.xml


# date de début et de fin 

annee_deb=$(echo $date_deb_form | awk -F"-" '{print $1}')
mois_deb=$(echo $date_deb_form | awk -F"-" '{print $2}')
jour_deb=$(echo $date_deb_form | awk -F"-" '{print $3}')

annee_fin=$(date --date=$date_deb_form"+$nb_jour days" +%Y)  # attention avec cette méthode on
mois_fin=$(date --date=$date_deb_form"+$nb_jour days" +%m)   # compte aussi comme jours de
jour_fin=$(date --date=$date_deb_form"+$nb_jour days" +%d)   # travail le samedi et dimanche

sed -i -E "s/\[date de début\]/$jour_deb ${months[$((mois_deb-1))]} $annee_deb/" content.xml
sed -i -E "s/\[date de fin\]/$jour_fin ${months[$((mois_fin-1))]} $annee_fin/" content.xml


### on renomme le fichier pdf créé

nbf=$( ls factures | wc -w )   # le nb de factures présentes dans le dossier 'factures'

mv factures/reziped_facture.pdf factures/Factures$nbf


