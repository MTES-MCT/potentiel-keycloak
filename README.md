# Système d'authentification avec Keycloak

Keycloak est un service open source d'identité et de gestion d'accès.
Cette page a pour but d'expliquer la configuration et l'usage de keycloak dans le cadre de Potentiel.
Vous pouvez aussi lire la [documentation officielle de Keycloak](https://www.keycloak.org/documentation).

Il existe deux environnements pour keycloak :

- Une version "legacy" est situé dans le repo [potentiel](https://github.com/MTES-MCT/potentiel); cet environnement est utilisé à des fins de tests en local **uniquement**
- Une version de production (ici) partagée entre les environnements de `staging` et `production`.

## Sommaire

- [Système d'authentification avec Keycloak](#système-dauthentification-avec-keycloak)
  - [Sommaire](#sommaire)
  - [Mise en oeuvre](#mise-en-oeuvre)
  - [Mise à jour du thème](#mise-à-jour-du-thème)
  - [Configuration de l'authentification à double facteur pour un role précis](#configuration-de-lauthentification-à-double-facteur-pour-un-role-précis)
    - [Créer un nouveau flow `Browser`](#créer-un-nouveau-flow-browser)
    - [Affecter le flow Browser au flow nouvellement créé](#affecter-le-flow-browser-au-flow-nouvellement-créé)
  - [Ajouter une configuration 2FA pour un nouveau rôle](#ajouter-une-configuration-2fa-pour-un-nouveau-rôle)
  - [Déployer une modification en production](#déployer-une-modification-en-production)

Pour en savoir plus sur l'utilisation en local, veuillez vous rendre sur la page [`https://github.com/MTES-MCT/potentiel/docs/KEYCLOAK.md`](https://github.com/MTES-MCT/potentiel/blob/master/docs/KEYCLOAK.md)

Si vous souhaitez en savoir plus sur l'utilisation en production, vous êtes au bon endroit.

## Mise en oeuvre

Keycloak tourne sur un serveur séparé. L'application peut le requêter pour les besoins d'authentification via le middleware `keycloak-connect` et la lib `keycloak-admin`.

`keycloak-connect` vérifie la présence et la validité d'un token de session Keycloak. S'il est manquant ou invalide, l'utilisateur est redirigé vers la page d'authentification du serveur keycloak. Après identification, l'utilisateur est redirigé sur Potentiel avec le bon token de session.
Le token de session contient l'email de l'utilisateur ainsi que son role. L'email de l'utilisateur est utilisé pour retrouver l'identifiant interne de celui-ci. L'objet `Request` de express est enrichi avec un `User`.

Ce mécanisme est mis en oeuvre via l'adaptateur [`makeKeycloakAuth`](https://github.com/MTES-MCT/potentiel/blob/master/src/infra/keycloak/makeKeycloakAuth.ts).

La création d'un utilisateur peut être faite soit par inscription de l'utilisateur (qui se fait via des écrans gérés par le serveur Keycloak lui-même), soit par création de compte initié par l'application (invitation d'un utilisateur lors d'une désignation ou parrainage par un autre porteur de projet).
Dans ce dernier cas, l'application utilise `keycloak-admin` pour demander la création de l'utilisateur à Keycloak (cf [`createUserCredentials`](<[../src/infra/keycloak-legacy/createUserCredentials.ts](https://github.com/MTES-MCT/potentiel/blob/master/src/infra/keycloak/createUserCredentials.ts)>))

Tous les mails d'authentification (invitation initiale, récupération de mot de passe) sont envoyés par Keycloak directement.

## Mise à jour du thème

Afin de brander keycloak aux couleurs de Potentiel, nous avons créer un theme `potentiel` qui contient tous les templates nécessaire au bon fonctionnement du système. Si vous avez besoin de mettre à jour le contenu ou la structure d'une page keycloak, ce sera dans ce dossier `themes/potentiel`.

## Configuration de l'authentification à double facteur pour un role précis

Pour se faire il faut se rendre dans la partie `Authentification` du realm concerné.

### Créer un nouveau flow `Browser`

1. Dans le menu `Authentication`
1. Dans l'onglet `Flows`
1. Faire une copie du flow `Browser` avec par exemple le nom `Browser with OTP for role`
1. Supprimer la partie `Browser - Conditional OTP`
1. Au niveau de l'étape `Browser with OTP for role`, supprimer l'exécution `Browser - Conditional OTP`
1. Ajouter une nouvelle exécution de type `Conditional OTP Form`
1. Modifer cette exécution pour être `REQUIRED`
1. Modifier la config de l'exécution :
   - Sélectionner le role voulu dans l'option `Force OTP for Role`
   - Sélectionner `skip` dans l'option `Fallback OTP handling`

### Affecter le flow Browser au flow nouvellement créé

1. Dans l'onglet `Bindings`
1. Sélectionner le flow `Browser with OTP for role` pour l'option `Browser Flow`
1. Sauvegarder

Désormais les utilisateurs avec le rôle spécifiés dans l'exécution `Browser - Conditional OTP` devront configurer une application comme FreeOTP ou Google Authenticator pour se connecter à Potentiel.

## Ajouter une configuration 2FA pour un nouveau rôle

Si la configutation de l'authentification à double facteur a déjà été créée, pour ajouter un nouveau rôle il suffit de cliquer sur l'option `Authentication` du menu latéral, dans l'onglet `Flows` à l'aide du menu déroulant sélectionner `Browser with OTP Required`, au niveau de la ligne `Browser With OTP Required Forms` dans les `actions`, choisir `add flow`. Nommer le flow de cette façon `Conditional OTP Form (OTP Required for [ROLE])`.
Dans les actions de la ligne nouvellement créée, choisir la `config` dans les actions :

- `Force OTP for Role` : choisir le rôle
- `Fallback OTP handling` : skip
- et enfin sauvegarger.

## Déployer une modification en production

Ce repo dispose d'une automatisation de mise en production sur notre hébergeur [Scalingo](https://scalingo.com/fr). La configuration est faite directement dans le dashboard Scalingo, donc le repo sur Scalingo va se mettre à jour dès qu'un push est fait sur la branche `main`.

💡 Il est cependant possible de déployer manuellement au besoin. Pour celà, il suivit de suivre ces étapes :

- avoir ce repository cloné en local
- avoir ajouté dans les remotes git l'url du repo fourni par Scalingo ([ici](https://dashboard.scalingo.com/apps/osc-secnum-fr1/keycloak-potentiel/deploy/config))
- lancer la commande (depuis un terminal local) : `git push **nom_remote** main:master`
  (exemple : `git push scalingo main:master`)