import  { minimatch as m } from 'minimatch'

export function minimatch(a){
  return function (b) {
    return m(a,b)
  }
}
