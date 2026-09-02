#include "authcontroller.h"

#include <QByteArray>

#include <cstdlib>
#include <cstring>
#include <security/pam_appl.h>

namespace {
struct PamData { QByteArray password; };

int conversation(int count, const pam_message **messages, pam_response **responses, void *data)
{
    if (count <= 0 || !messages || !responses || !data)
        return PAM_CONV_ERR;
    auto *pamData = static_cast<PamData *>(data);
    auto *reply = static_cast<pam_response *>(calloc(static_cast<size_t>(count), sizeof(pam_response)));
    if (!reply)
        return PAM_BUF_ERR;
    for (int index = 0; index < count; ++index) {
        if (messages[index]->msg_style == PAM_PROMPT_ECHO_OFF
            || messages[index]->msg_style == PAM_PROMPT_ECHO_ON)
            reply[index].resp = strdup(pamData->password.constData());
    }
    *responses = reply;
    return PAM_SUCCESS;
}
}

AuthController::AuthController(QObject *parent)
    : QObject(parent)
{
}

bool AuthController::authenticate(const QString &password)
{
    PamData data{password.toUtf8()};
    pam_conv conv{conversation, &data};
    pam_handle_t *handle = nullptr;
    const QByteArray user = qEnvironmentVariable("USER").toUtf8();
    int result = pam_start("login", user.constData(), &conv, &handle);
    if (result == PAM_SUCCESS)
        result = pam_authenticate(handle, PAM_SILENT);
    if (handle)
        pam_end(handle, result);
    data.password.fill('\0');

    if (result == PAM_SUCCESS) {
        m_error.clear();
        emit errorChanged();
        emit unlocked();
        return true;
    }
    m_error = QStringLiteral("That password was not accepted.");
    emit errorChanged();
    return false;
}
