# Système d'authentification avec Keycloak

Keycloak est un service open source d'identité et de gestion d'accès.
Cette page a pour but d'expliquer la configuration et l'usage de keycloak dans le cadre de Potentiel.
Vous pouvez aussi lire la [documentation officielle de Keycloak](https://www.keycloak.org/documentation).

## Sommaire

- [Système d'authentification avec Keycloak](#système-dauthentification-avec-keycloak)
  - [Sommaire](#sommaire)
  - [Mise en oeuvre](#mise-en-oeuvre)
  - [Mise à jour du thème](#mise-à-jour-du-thème)
  - [Créer un nouveau flow `Browser`](#créer-un-nouveau-flow-browser)
  - [Activer la configuration avec OTP (2FA) en local](#activer-la-configuration-avec-otp-2fa-en-local)
  - [Configurer l'envoi d'email en local](#configurer-lenvoi-demail-en-local)
  - [Déployer une modification en production](#déployer-une-modification-en-production)
  - [Mettre à jour la version de Keycloak](#mettre-à-jour-la-version-de-keycloak)

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

## Créer un nouveau flow `Browser`

1. Dans le menu `Authentication`
2. Dans l'onglet `Flows`
3. Faire une copie du flow `Browser` avec par exemple le nom `Browser with OTP for role`
4. Supprimer la partie `Browser - Conditional OTP`
5. Au niveau de l'étape `Browser with OTP for role`, supprimer l'exécution `Browser - Conditional OTP`
6. Ajouter une nouvelle exécution de type `Conditional OTP Form`
7. Modifer cette exécution pour être `REQUIRED`
8. Modifier la config de l'exécution :
   - Sélectionner le role voulu dans l'option `Force OTP for Role`
   - Sélectionner `skip` dans l'option `Fallback OTP handling`


## Activer la configuration avec OTP (2FA) en local

Par défaut, lors de l’import du realm, le flow de connexion browser n'utilise pas l’OTP. Pour activer cette authentification à double facteur, il suffit de suivre ces étapes : 

- Aller dans le realm concerné, puis sur « Authentification »
- Cliquer sur les trois petites points de la ligne « browser » et choisir « Bind Flow »
- Sélectionner ensuite « browser with OTP required » et enregistrer

La configuration est maintenant activée. Si vous vous connectez avec un profil administrateur vous aurez la page de configuration de l'authentification à double facteur.

N.B : Par défaut, les rôles qui ont le 2FA d'activé sont :
- administrateur
- dgec-validateur
- cre
- acheteur-obligé

Si vous avez besoin d'ajouter un nouveau rôle, il faudra : 
- éditer le flow "browser with OTP required"
- ajouter un sous-step de type "Condtionnal OTP Form" au step "browser with OTP required forms"
- Selectionner le rôle concerné dans "Force OTP for Role"
- enregistrer

## Configurer l'envoi d'email en local

Pour pouvoir tester les emails dans l’environnement local, il faut au préalable avoir importé le realm. Ensuite, il suffit de suivre ces étapes : 

- Aller dans les paramètres du royaume (Realm settings) > onglet  « Email »
- Renseigner toutes les informations « From », « Host » et « Port », « Enable StartTLS » en se basant sur ce que l’on trouve en [production](https://auth.potentiel.beta.gouv.fr/admin/master/console/#/realms/Potentiel/smtp-settings) 
- Activer l’authentification et renseigner les credentials de connexion (penser à avoir dans son fichier d’environnement les variables `MJ_APIKEY_PUBLIC` et `MJ_APIKEY_PRIVATE`

Si besoin vous pouvez tester la connexion en suivant les étapes proposées sur l’interface.

## Déployer une modification en production

Ce repo dispose d'une automatisation de mise en production sur notre hébergeur [Scalingo](https://scalingo.com/fr). La configuration est faite directement dans le dashboard Scalingo, donc le repo sur Scalingo va se mettre à jour dès qu'un push est fait sur la branche `main`.

💡 Il est cependant possible de déployer manuellement au besoin. Pour celà, il suivit de suivre ces étapes :

- avoir ce repository cloné en local
- avoir ajouté dans les remotes git l'url du repo fourni par Scalingo ([ici](https://dashboard.scalingo.com/apps/osc-secnum-fr1/keycloak-potentiel/deploy/config))
- lancer la commande (depuis un terminal local) : `git push **nom_remote** main:master`
  (exemple : `git push scalingo main:master`)


> ⚠️ Il est possible que suite à un déploiement le thème keycloak DSFR ne soit pas trouvé, dans le cas là il sera nécessaire de refaire un déploiement manuel ⚠️

## Mettre à jour la version de Keycloak

Afin d'éviter toute faille de sécurité il est important de faire la mise à jour de Keycloak sur le serveur.
Pour celà, il faut suivre les étapes suivantes : 

1. Mettre à jour la version du [docker compose](https://github.com/MTES-MCT/potentiel/blob/a7f3fbe59a26542501d8ce2e32615e4d7d867f33/docker-compose.yml#L43C35-L43C35) en ajoutant la version à la fin du nom de l'image. Exemple : `quay.io/keycloak/keycloak:23.0.4`
2. Mettre à jour les dépendances keycloak du projet
  ```
  npm i @keycloak/keycloak-admin-client@latest
  npm i keycloak-connect@latest 
  ``` 
3. Mettre à jour le repo potentiel-keycloak depuis le projet potentiel
   ```
   git submodule sync
   git submodule update --init
   ```
4. Mettre à jour le container sur [scalingo](https://dashboard.scalingo.com/apps/osc-secnum-fr1/keycloak-potentiel/environment)
  - Changer la variable d'environnement `KEYCLOAK_VERSION`
  - relancer le process scalingo
