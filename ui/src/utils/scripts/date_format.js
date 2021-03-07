function formatDate (date, options) {
  const dateTime = new Date(date)

  if (dateTime.toLocaleString) {
    return new Date(date).toLocaleString('en-US', options)
  } else {
    return dateTime.toString()
  }
}

function timeDiff (timeA, timeB) {
  const dateA = new Date(timeA)
  const dateB = new Date(timeB)

  const diffInSeconds = (dateB.getTime() - dateA.getTime()) / 1000

  if (diffInSeconds < 60) {
    const diff = parseInt(diffInSeconds) || 1
    return `${diff} second${diff > 1 ? 's' : ''}`
  } else if (diffInSeconds < 60 * 60) {
    const diff = parseInt(diffInSeconds / 60) || 1
    return `${diff} minute${diff > 1 ? 's' : ''}`
  } else {
    const diff = parseInt(diffInSeconds / (60 * 60)) || 1
    return `${diff} hour${diff > 1 ? 's' : ''}`
  }
}

export { formatDate, timeDiff }
