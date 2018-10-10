class ResponseException(Exception):
    """ Exception wrapper to be used in an http response, allows exceptions to specify status codes when raised """

    def __init__(
        self, message, status=500, error_class=None, error_type=None, **kwargs
    ):
        """ Create a new ResponseException
        Args:
            message: Message to be attached to exception
            status: HTTP status code to be returned with this exception
            error_class: Nested exception will be created of this class if included
            error_type: Type ID written to error DB, should be one of the values in
            dataactvalidator.validation_handlers.validationError.py
            **kwargs: Additional fields to be attached to exception, primarily used for providing extra data to error DB
        Returns:
            ResponseException object
        """
        super(ResponseException, self).__init__(message)
        self.status = (
            status
        )  # This will be used for the HTTP response status code, 500 if unspecified
        self.errorType = error_type  # This is used for writing to the error DB
        self.extraInfo = {}
        for key in kwargs:
            # Include extra error info
            self.extraInfo[key] = kwargs[
                key
            ]  # This can be written to the error DB for some error types
        if error_class is None:
            self.wrappedException = (
                None
            )  # Can be used to wrap another type of exception into a ResponseException
        else:
            try:
                self.wrappedException = error_class(message)
            except Exception:
                # Some errors cannot be created with just a message, in that case create a string representation
                self.wrappedException = str(error_class) + str(message)
