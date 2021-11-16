using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Puzzel : MonoBehaviour
{
    public Piece[] p;
    private bool canMove;
    private void Start()
    {
        for (int i = 0; i < p.Length; i++) p[i].currPos = i;
        canMove = true;
    }
    public void RandomPuzzel()
    {

    }
    public void check()
    {

    }
    public void SetCanMove(bool move) { canMove = move; }
    public bool Canmove() { return canMove; }
}
