<!-- Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/ -->

<script setup lang="ts">
import { FormKit } from '@formkit/vue'
</script>

<template>
  <Story>
    <Variant title="Default">
      <FormKit type="time" label="Time" name="time" />
    </Variant>
  </Story>
</template>
