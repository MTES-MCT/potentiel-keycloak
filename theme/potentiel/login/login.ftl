<#import "template.ftl" as layout>
  <@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') title=msg("loginTitle") displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section="header">
      ${msg("doLogIn")}
    <#elseif section="form">
      <section class="${properties.layoutClass!}">
        <h1>Connexion à Potentiel</h1>

        <h2>Se connecter avec son compte</h2>

        <div id="kc-form" class="fr-mb-6v">
          <#if realm.password>
            <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
              <#if message?has_content>
                <#if message.type=='error'>
                  <div class="${properties.kcAlertClass!} ${properties.kcAlertErrorClass!} fr-my-4v">
                    ${kcSanitize(message.summary)?no_esc}
                  </div>
                  <#elseif message.type=='warning'>
                    <div class="${properties.kcAlertClass!} ${properties.kcAlertWarningClass!}">
                      ${kcSanitize(message.summary)?no_esc}
                    </div>
                  <#else>
                    <div class="${properties.kcAlertClass!} ${properties.kcAlertSuccessClass!}">
                      ${kcSanitize(message.summary)?no_esc}
                    </div>
                </#if>
              </#if>
              <div class="${properties.kcFormGroupClass!}">
                <label for="username" class="${properties.kcLabelClass!}">
                  Identifiant
                  <span class="fr-hint-text">Le format attendu est votre courrier éléctronique</span>
                </label>
                <#if usernameEditDisabled??>
                  <input id="username" class="${properties.kcInputClass!}" name="username" value="${(login.username!'')}" type="text" disabled />
                <#else>
                  <input id="username" class="${properties.kcInputClass!}" name="username" value="${(login.username!'')}" type="text" autofocus autocomplete="off"
                  aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>" />
                </#if>
              </div>
              <div class="${properties.kcFormGroupClass!}">
                <div class="fr-password" id="password-1758"> 
                  <label class="${properties.kcLabelClass!} fr-label" for="password"> Mot de passe </label>
                  <input class="fr-password__input fr-input" aria-required="true" name="password" autocomplete="current-password" id="password-1758-input" type="password"> 
                  <div class="fr-password__checkbox fr-checkbox-group fr-checkbox-group--sm"> 
                    <input aria-label="Afficher le mot de passe" id="password-1758-show" type="checkbox" aria-describedby="password-1758-show-messages"> 
                    <label class="fr-password__checkbox fr-label" for="password-1758-show"> Afficher </label>
                  </div>
                  <a href="${url.loginResetCredentialsUrl}" class="block w-fit fr-link fr-my-6v ">Mot de passe oublié</a>
                </div>
              </div>
              <div class="${properties.kcFormGroupClass!} fr-grid-row fr-grid-row--bottom fr-mt-8v">
                <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                <button class="${properties.kcButtonClass!} w-full items-center" name="login" id="kc-login" type="submit">Je m'identifie</button>
              </div>
            </form>
          </#if>
        </div>
        <h2>Vous n'avez pas de compte ?</h2>
        <a href="${properties.potentielUrl}/auth/signUp" class="fr-btn fr-btn--secondary w-full items-center">Je crée mon compte Potentiel</a>
      </section>
    <#elseif section="info">
    </#if>
  </@layout.registrationLayout>