import { Next } from 'koa';
import Joi from 'joi';

type ValidationLocation = 'body' | 'query' | 'params';

interface ValidationOptions {
  location?: ValidationLocation;
  abortEarly?: boolean;
  stripUnknown?: boolean;
}

export const validate = (schema: Joi.Schema, options: ValidationOptions = {}): any => {
  const {
    location = 'body',
    abortEarly = false,
    stripUnknown = true
  } = options;

  return async (ctx: any, next: Next): Promise<void> => {
    const data = ctx[location];

    const { error, value } = schema.validate(data, {
      abortEarly,
      stripUnknown,
      allowUnknown: false,
      convert: true
    });

    if (error) {
      const errorMessage = error.details[0].message;
      ctx.badRequest(errorMessage);
      return;
    }

    ctx.state.validatedData = value;
    await next();
  };
};

export const validateBody = (schema: Joi.Schema, options?: Omit<ValidationOptions, 'location'>): any => {
  return validate(schema, { ...options, location: 'body' });
};

export const validateQuery = (schema: Joi.Schema, options?: Omit<ValidationOptions, 'location'>): any => {
  return validate(schema, { ...options, location: 'query' });
};

export const validateParams = (schema: Joi.Schema, options?: Omit<ValidationOptions, 'location'>): any => {
  return validate(schema, { ...options, location: 'params' });
};
