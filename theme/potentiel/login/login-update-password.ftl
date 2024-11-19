<#import "template.ftl" as layout>
<#import "password-commons.ftl" as passwordCommons>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-confirm'); section>
    <#if section = "header">
        ${msg("updatePasswordTitle")}
    <#elseif section = "form">
        <form id="kc-passwd-update-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">

            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcAlertInfoClass!}">
                    ${msg("passwordRules")}
                </div>
            </div>

        <#if message?has_content>
          <#if message.type=='error'>
            <div class="${properties.kcAlertClass!} ${properties.kcAlertErrorClass!} fr-mb-8v">
              ${kcSanitize(message.summary)?no_esc}
            </div>
          <#elseif message.type=='warning'>
              <div class="${properties.kcAlertClass!} ${properties.kcAlertWarningClass!} fr-mb-8v">
                ${kcSanitize(message.summary)?no_esc}
              </div>
          <#else>
            <div class="${properties.kcAlertClass!} ${properties.kcAlertSuccessClass!} fr-mb-8v">
              ${kcSanitize(message.summary)?no_esc}
            </div>
          </#if>
        </#if>

            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="password-new" class="${properties.kcLabelClass!}">${msg("passwordNew")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <div class="${properties.kcInputGroup!}" dir="ltr">
                        <input type="password" id="password-new" name="password-new" class="${properties.kcInputClass!}"
                            autofocus autocomplete="new-password"
                            aria-invalid="<#if messagesPerField.existsError('password','password-confirm')>true</#if>"
                        />
                    </div>

                    <#if messagesPerField.existsError('password')>
                        <span id="input-error-password" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('password'))?no_esc}
                        </span>
                    </#if>
                </div>
            </div>

            <div class="${properties.kcFormGroupClass!}">
                <div class="${properties.kcLabelWrapperClass!}">
                    <label for="password-confirm" class="${properties.kcLabelClass!}">${msg("passwordConfirm")}</label>
                </div>
                <div class="${properties.kcInputWrapperClass!}">
                    <div class="${properties.kcInputGroup!}" dir="ltr">
                        <input type="password" id="password-confirm" name="password-confirm"
                               class="${properties.kcInputClass!}"
                               autocomplete="new-password"
                               aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>"
                        />
                    </div>

                    <#if messagesPerField.existsError('password-confirm')>
                        <span id="input-error-password-confirm" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                            ${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}
                        </span>
                    </#if>

                </div>
            </div>

            <div class="${properties.kcFormGroupClass!}">
                <@passwordCommons.logoutOtherSessions/>

                <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                    <#if isAppInitiatedAction??>
                        <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}" />
                        <button class="${properties.kcButtonClass!} ${properties.kcButtonDefaultClass!} ${properties.kcButtonLargeClass!}" type="submit" name="cancel-aia" value="true" />${msg("doCancel")}</button>
                    <#else>
                        <input class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}" />
                    </#if>
                </div>
            </div>
        </form>
        <script type="module" src="${url.resourcesPath}/js/passwordVisibility.js"></script>
    </#if>
</@layout.registrationLayout>
