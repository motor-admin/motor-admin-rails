function formatDate (date, options, displayTime) {
  const dateTime = new Date(date)

  options ||= {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  }

  if (displayTime) {
    options.hour = 'numeric'
    options.minute = 'numeric'
    options.hour12 = true
  }

  if (dateTime.toLocaleString) {
    return dateTime.toLocaleString('en-US', options)
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
