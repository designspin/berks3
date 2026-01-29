import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Berks 3",
  description: "A faithful remake of the 1985 8-bit classic by Jon Williams",
  base: '/berks3/',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'How to Play', link: '/how-to-play' },
      { text: 'Controls', link: '/controls' }
    ],

    sidebar: [
      {
        text: 'Guide',
        items: [
          { text: 'How to Play', link: '/how-to-play' },
          { text: 'Controls', link: '/controls' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/designspin/berks3' }
    ]
  }
})
