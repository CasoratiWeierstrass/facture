Un script pour générer automatiquement des factures à partir d'un fichier facture type.

Dans le projet, vous pouvez trouver :

- l'énoncé du projet

- le fichier facture type (que vous pouvez modifier selon vos besoins, mais attention aux bêtises)

- un fichier 'corps_de_mail' contenant un texte par défaut si vous envoyez automatiquement vos factures (vous pouvez le modifier selon vos souhaits)

- le script effectuant toutes les tâches de modifications (obtenez de l'aide avec l'argument --help lors de son exécution)


Comme dit plus haut, ce script générère automatiquement une facture à partir du fichier type et des quelques informations que vous fournissez à l'exécution.
Lorsque vous générez une facture, celle-ci est automatiquement placée dans le répertoire 'factures' dans le répertoire où se trouve le script (si ce répertoire n'existe pas, il est créé automatiquement)
Dans ce répertoire, votre facture générée se nomme 'FactureX' où X est le nombre de facture présentes dans le dossier. Elle est donc facile à retrouver car à l'instant où vous la générez, elle est la "dernière" facture du dossier (celle avec le nombre le plus haut).
Lorsqu'elle est générée, il vous faut donc la déplacer et la renommer vous-même.
Il est conseillé de ne pas mettre n'importe quoi dans le dossier 'factures', pour éviter les problèmes lors de l'export des factures.
Vous pouvez si vous le spécifiez lorsque cela vous est demandé par le script automatiquement envoyer une facture fraîchement générée par mail. Suivez les instructions.
