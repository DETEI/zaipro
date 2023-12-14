// Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

import { computed } from 'vue'
import type { Props } from './CommonIcon.vue'
import type { Animations, Sizes } from './types.ts'

export const usePrivateIcon = (
  props: Omit<Props, 'size'> & { size: Sizes },
) => {
  const animationClassMap: Record<Animations, string> = {
    pulse: 'animate-pulse',
    spin: 'animate-spin',
    ping: 'animate-ping',
    bounce: 'animate-bounce',
  }

  const sizeMap: Record<Sizes, number> = {
    xs: 12,
    tiny: 16,
    small: 20,
    base: 24,
    medium: 32,
    large: 48,
    xl: 96,
  }

  const iconClass = computed(() => {
    let className = `icon-${props.name}`
    if (props.animation) {
      className += ` ${animationClassMap[props.animation]}`
    }
    return className
  })

  const finalSize = computed(() => {
    if (props.fixedSize) return props.fixedSize

    return {
      width: sizeMap[props.size],
      height: sizeMap[props.size],
    }
  })

  return {
    iconClass,
    finalSize,
  }
}
