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
      x_1_5: false,
      x_3_4: false,
      x_5_6: false,
      x_5_7: false,
      x_7_8: false,
      x_8_9: false,
      x_1_10: false,
      x_1_3: false,
      x_17_18: false,
      x_18_19: false,
      x_10_11: false,
      x_12_13: false,
      x_13_14: false,
      x_15_16: false,
      x_10_12: false,
      x_15_17: false,
      x_10_15: false,
      x_1_2: false,
    }
  },
  computed: {
    answer_1_2() {
      return (1)
    },
    answer_2_3() {
      return (2)
    },
    answer_3_4() {
      return (3)
    },
    answer_4_5() {
      return (4)
    },
    answer_5_6() {
      return (5)
    },
    answer_6_7() {
      return (6)
    },
    answer_7_8() {
      return (7)
    },
    answer_8_9() {
      return (8)
    },
    answer_9_10() {
      return (9)
    },
    answer_10_11() {
      return (10)
    },
    answer_11_12() {
      return (11)
    },
    answer_12_13() {
      return (12)
    },
    answer_13_14() {
      return (13)
    },
    answer_14_15() {
      return (14)
    },
    answer_15_16() {
      return (15)
    },
    answer_16_17() {
      return (16)
    },
    answer_17_18() {
      return (17)
    },
    answer_18_19() {
      return (18)
    },
    answer_19_20() {
      return (19)
    },

  },
}).mount("#app");