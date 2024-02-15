package services

import (
	"fmt"

	"github.com/go-playground/validator/v10"
)

type ValidateErrorResponse struct {
	Error       bool        `json:"error"`
	FailedField string      `json:"failedField"`
	Tag         string      `json:"tag"`
	Value       interface{} `json:"value"`
}

type Response struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

type XValidator struct {
	validator *validator.Validate
}

var validate = validator.New()

func (v XValidator) Validate(data interface{}) []ValidateErrorResponse {
	validationErrors := []ValidateErrorResponse{}

	errs := validate.Struct(data)
	if errs != nil {
		for _, err := range errs.(validator.ValidationErrors) {
			// In this case data object is actually holding the User struct
			var elem ValidateErrorResponse

			elem.FailedField = err.Field() // Export struct field name
			elem.Tag = err.Tag()           // Export struct tag
			elem.Value = err.Value()       // Export field value
			elem.Error = true

			validationErrors = append(validationErrors, elem)
		}
	}

	return validationErrors
}

func (v XValidator) GetMessage(data interface{}) Response {
	if errs := v.Validate(data); len(errs) > 0 && errs[0].Error {
		err := errs[0]
		msg := fmt.Sprintf(
			"[%s]: '%v' | Needs to implement '%s'",
			err.FailedField,
			err.Value,
			err.Tag,
		)

		return Response{
			Success: false,
			Message: msg,
		}
	}

	return Response{
		Success: true,
	}
}

var Validator = &XValidator{
	validator: validate,
}
