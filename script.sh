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
		   (l'argument doit être donné au format anglais année-mois-jour : 2000-01-01)
		-> le nombre de jour que dure la formation: '-nj=[nb_jour]'
		"""
		exit 2
	elif [[ $arg =~ ^-nf=([0-9]+)$ ]]
	then
		num_fact=${BASH_REMATCH[1]}
	
	elif [[ $arg =~ ^-mj=([0-9]{1,3})$ ]]
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



### on s'assure que tous les paramètres nécessaires ont bien été fournis

if [ -e $num_fact ] || [ -e $mont_jour ] || [ -e $date_deb_form ] || [ -e nb_jour ]
then
	echo "Il manque au moins un argument pour exécuter le script (consultez l'aide: --help)"
	exit 1
fi



echo "Génération de votre facture en cours . . ."

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



### Modification du nombre de jours de la formation

sed -i -E "s/\[nombre de jours\]/$nb_jour/" content.xml



### Modification des dates

months=(Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre)

# date de création de la facture

ac=$( date +%Y ) ; mc=$( date +%m ) ; jc=$( date +%d )   # l'année, le mois et le jour courant (pour établir la facture au jour où elle est générée)

sed -i -E "s/date création facture/$jc ${months[$((mc-1))]} $ac/" content.xml


# date de début et de fin 

annee_deb=$(echo $date_deb_form | awk -F"-" '{print $1}')
mois_deb=$(echo $date_deb_form | awk -F"-" '{print $2}')
jour_deb=$(echo $date_deb_form | awk -F"-" '{print $3}')

annee_fin=$(date --date=$date_deb_form"+$nb_jour days" +%Y)  # attention avec cette méthode on
mois_fin=$(date --date=$date_deb_form"+$nb_jour days" +%m)   # compte aussi comme jours de
jour_fin=$(date --date=$date_deb_form"+$nb_jour days" +%d)   # travail le samedi et dimanche

sed -i -E "s/\[date de début\]/$jour_deb ${months[$((mois_deb-1))]} $annee_deb/" content.xml
sed -i -E "s/\[date de fin\]/$jour_fin ${months[$((mois_fin-1))]} $annee_fin/" content.xml



### on rezip le fichier dézipé

zip -r ../reziped_facture . &>/dev/null



### on génère le pdf à partir du fichier au contenu modifié

soffice --headless --convert-to pdf:calc_pdf_Export --outdir ../factures ../reziped_facture.zip &>/dev/null
cd ..



### on nettoie un peu ce qu'on a créé

rm -r unziped_facture reziped_facture.zip



### on renomme le fichier pdf créé

nbf=$( ls factures | wc -w )   # le nb de factures présentes dans le dossier 'factures' (en comptant celle qui vient d'être créée)

mv factures/reziped_facture.pdf factures/Facture$nbf



echo -e "[DONE]\n"



### Envoi automatique par mail de la facture

send=non

read -p "Voulez-vous envoyer cette facture par mail directement ? (o/N) " send

if [[ $send =~ (OUI|Oui|oui|o|O|YES|Yes|yes|y|Y) ]]
then
	read -p "Entrez l'adresse mail où envoyer la facture: " adr_mail
	if ! [[ $adr_mail =~  [^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+ ]] # la regex de ihateregex.io sur les adresses mail
	then
		echo "adresse fournie invalide"
		exit 1
	fi

else
	echo -e "Pas d'envoi automatique\n"
fi

