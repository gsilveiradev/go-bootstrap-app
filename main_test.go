package main

import (
	"bytes"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMain_printMe(t *testing.T) {
	tt := []struct {
		testCase string
		message  string
		expect   string
	}{
		{
			"Should print empty message",
			"",
			"\n",
		},
		{
			"Should print 'testing 123'",
			"testing 123",
			"testing 123\n",
		},
		{
			"Should print 'Something else 12345!'",
			"Something else 12345!",
			"Something else 12345!\n",
		},
	}

	for _, tc := range tt {
		t.Run(tc.testCase, func(t *testing.T) {
			var output bytes.Buffer
			printMe(&output, tc.message)
			assert.Equal(t, tc.expect, output.String())
		})
	}
}
