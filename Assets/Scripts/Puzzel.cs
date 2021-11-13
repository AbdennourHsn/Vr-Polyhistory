using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Puzzel : MonoBehaviour
{
    public Piece[] p;

    private void Start()
    {
        for (int i = 0; i < p.Length; i++) p[i].currPos = i;
    }
    public void RandomPuzzel()
    {

    }
    public void check()
    {

    }
}
