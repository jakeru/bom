<template>
  <v-app>
    <v-app-bar
      app
      color="primary"
      dark
    >
      <div class="d-flex align-center">
        BOMSplitter by Jabbe v1.0 rel 2020-04-12
      </div>

      <v-spacer></v-spacer>

      <v-btn
        href="https://github.com/jakeru/bom"
        target="_blank"
        text
      >
        <span class="mr-2">Source code</span>
        <v-icon>mdi-open-in-new</v-icon>
      </v-btn>
    </v-app-bar>

    <v-content>
      <BOM />
    </v-content>
  </v-app>
</template>

<script>
import BOM from './components/BOM';

export default {
  name: 'App',

  components: {
    BOM,
  },

  data: () => ({
    //
  }),
};
</script>
