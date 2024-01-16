import { StrInput, BoolInput, IntInput, ComputedInput } from './components.js';
const { createApp } = Vue;

createApp({
  components: {
    StrInput,
    BoolInput,
    IntInput,
    ComputedInput,
  },
  data() {
    return {
      hasMaintLoan: false,
      hasSoldHouse: false,
      privateDebt: 0,
      sellingPrice: 0,
      hasBoughtHouse: false,
    }
  },
  computed: {
    valueResidue() {
      return this.sellingPrice - this.privateDebt
    },

  },
}).mount("#app");