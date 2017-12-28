import json
import logging
import traceback

import flask

from webservices.tasks.response_exception import ResponseException

logger = logging.getLogger(__name__)


class JsonResponse:
    """ Used to create an http response object containing JSON """
    debugMode = True

    @staticmethod
    def create(code, dictionary_data):
        """
        Creates a JSON response object
        if debugMode is enabled errors are added
        """
        jsondata = flask.Response()
        jsondata.headers["Content-Type"] = "application/json"
        jsondata.status_code = code
        jsondata.set_data(json.dumps(dictionary_data))
        return jsondata

    @staticmethod
    def error(exception, error_code, **kwargs):
        """ Create an http response object for specified error. We assume
        we're in an exception context
        Args:
            exception: Exception to be represented by response object
            error_code: Status code to be used in response
            kwargs: Extra fields and values to be included in response
        Returns:
            Http response object containing specified error
        """
        response_dict = {}
        for key in kwargs:
            response_dict[key] = kwargs[key]

        trace = traceback.extract_tb(exception.__traceback__, 10)
        logger.exception('Route Error')
        if JsonResponse.debugMode:
            response_dict["message"] = str(exception)
            response_dict["errorType"] = str(type(exception))
            if isinstance(exception, ResponseException) and exception.wrappedException:
                response_dict["wrappedType"] = str(type(exception.wrappedException))
                response_dict["wrappedMessage"] = str(exception.wrappedException)
            response_dict["trace"] = [str(entry) for entry in trace]
            return JsonResponse.create(error_code, response_dict)
        else:
            response_dict["message"] = "An error has occurred"
            return JsonResponse.create(error_code, response_dict)