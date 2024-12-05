import nanomatch from 'nanomatch'

export const isMatch = (value) => (pattern) => {
  return nanomatch.isMatch(value, pattern)
}

export const capture = (pattern) => (value) => {
  return nanomatch.capture(pattern, value) || []
}
