# hubot-stm32

A hubot script that links documentation for [STM32 microcontrollers](https://www.st.com/en/microcontrollers/stm32-32-bit-arm-cortex-mcus.html).

See [`src/stm32.coffee`](src/stm32.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-stm32 --save`

Then add **hubot-stm32** to your `external-scripts.json`:

```json
[
  "hubot-stm32"
]
```

## Sample Interaction

```
user1>> hubot reference stm32f103rb
hubot>> Reference manual for STM32F103RBTx: http://www.st.com/resource/en/reference_manual/CD00171190.pdf
        (STM32F101xx, STM32F102xx, STM32F103xx, STM32F105xx and STM32F107xx advanced Arm®-based 32-bit MCUs)
```

## NPM Module

https://www.npmjs.com/package/hubot-stm32

## Disclaimer

All trademarks belong to their respective owners. 'STM32' is a registered trademark
of STMicroelectronics International N.V.
