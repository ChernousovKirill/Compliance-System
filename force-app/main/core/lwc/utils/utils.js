import errorLogger from '@salesforce/apex/LoggerUtil.errorLwc'

const parseErrorMessage = (mess) => {
    let errorMessage;

    try {
        if (JSON.parse(mess) && JSON.parse(mess).hasOwnProperty("description")) {
            errorMessage = JSON.parse(mess).description;
        }
    } catch (e) {
        errorMessage = mess;
    }

    return errorMessage;
}

const formatError = (error) => {
    let errorMessage;

    try {
        errorMessage = error.body.message;
    } catch (e) {
        errorMessage = e;
    }

    return errorMessage;
}

export {parseErrorMessage, formatError, errorLogger}