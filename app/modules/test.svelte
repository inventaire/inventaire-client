<p>
  Hello { name }, the time is <span class="the-time">{ hours }:{ minutes }:{ seconds }</span>
</p>

<style>
  .the-time {
    font-weight: bold;
  }
</style>

<script>
  import { onMount } from 'svelte'

  // Uncomment to test error stack trace
  // this will blow up
  // let foo = undefined
  // console.log(foo.bar())

  export let name = app.user.get('username')
  let time = new Date()

  onMount(() => {
    const timer = setInterval(() => {
      time = new Date()
    }, 1000)

    return () => {
      clearInterval(timer)
    }
  })

  let hours, minutes, seconds

  $: {
    hours = time.getHours()
    minutes = time.getMinutes()
    seconds = time.getSeconds()
  }
</script>
